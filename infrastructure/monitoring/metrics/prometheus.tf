# Comprehensive Prometheus Monitoring for Financial-Grade Observability
# Implements metrics collection, alerting, and long-term storage

# EKS Cluster for Monitoring Stack
resource "aws_eks_cluster" "monitoring" {
  name     = "${var.environment}-chainocracy-monitoring"
  role_arn = var.eks_cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.monitoring_access_cidrs
    security_group_ids      = [var.monitoring_security_group_id]
  }

  encryption_config {
    provider {
      key_arn = var.kms_key_arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
    aws_cloudwatch_log_group.monitoring_cluster
  ]

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-monitoring-cluster"
    Environment = var.environment
    Purpose = "monitoring"
  })
}

# CloudWatch Log Group for EKS Cluster
resource "aws_cloudwatch_log_group" "monitoring_cluster" {
  name              = "/aws/eks/${var.environment}-chainocracy-monitoring/cluster"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_logs_key_id

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-monitoring-cluster-logs"
    Environment = var.environment
  })
}

# EKS Node Group for Monitoring
resource "aws_eks_node_group" "monitoring" {
  cluster_name    = aws_eks_cluster.monitoring.name
  node_group_name = "${var.environment}-chainocracy-monitoring-nodes"
  node_role_arn   = var.eks_node_group_role_arn
  subnet_ids      = var.private_subnet_ids

  capacity_type  = "ON_DEMAND"
  instance_types = var.monitoring_instance_types

  scaling_config {
    desired_size = var.monitoring_desired_capacity
    max_size     = var.monitoring_max_capacity
    min_size     = var.monitoring_min_capacity
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    id      = aws_launch_template.monitoring_nodes.id
    version = aws_launch_template.monitoring_nodes.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_readonly
  ]

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-monitoring-node-group"
    Environment = var.environment
  })
}

# Launch Template for Monitoring Nodes
resource "aws_launch_template" "monitoring_nodes" {
  name_prefix   = "${var.environment}-chainocracy-monitoring-"
  image_id      = var.eks_optimized_ami_id
  instance_type = var.monitoring_instance_types[0]

  vpc_security_group_ids = [var.monitoring_security_group_id]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.monitoring_volume_size
      volume_type          = "gp3"
      encrypted            = true
      kms_key_id          = var.kms_ebs_key_id
      delete_on_termination = true
    }
  }

  user_data = base64encode(templatefile("${path.module}/user_data/monitoring_node.sh", {
    cluster_name = aws_eks_cluster.monitoring.name
    environment  = var.environment
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.environment}-chainocracy-monitoring-node"
      Environment = var.environment
    })
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-monitoring-launch-template"
    Environment = var.environment
  })
}

# Kubernetes Namespace for Monitoring
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name = "monitoring"
      environment = var.environment
    }
  }

  depends_on = [aws_eks_cluster.monitoring]
}

# Prometheus ConfigMap
resource "kubernetes_config_map" "prometheus_config" {
  metadata {
    name      = "prometheus-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "prometheus.yml" = templatefile("${path.module}/config/prometheus.yml", {
      environment = var.environment
      cluster_name = aws_eks_cluster.monitoring.name
    })
    "alert_rules.yml" = file("${path.module}/config/alert_rules.yml")
  }

  depends_on = [kubernetes_namespace.monitoring]
}

# Prometheus Deployment
resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      app = "prometheus"
      environment = var.environment
    }
  }

  spec {
    replicas = var.prometheus_replicas

    selector {
      match_labels = {
        app = "prometheus"
      }
    }

    template {
      metadata {
        labels = {
          app = "prometheus"
          environment = var.environment
        }
      }

      spec {
        service_account_name = kubernetes_service_account.prometheus.metadata[0].name

        container {
          name  = "prometheus"
          image = "prom/prometheus:${var.prometheus_version}"

          port {
            container_port = 9090
            name          = "web"
          }

          args = [
            "--config.file=/etc/prometheus/prometheus.yml",
            "--storage.tsdb.path=/prometheus/",
            "--web.console.libraries=/etc/prometheus/console_libraries",
            "--web.console.templates=/etc/prometheus/consoles",
            "--storage.tsdb.retention.time=${var.prometheus_retention}",
            "--web.enable-lifecycle",
            "--web.enable-admin-api"
          ]

          volume_mount {
            name       = "prometheus-config"
            mount_path = "/etc/prometheus"
          }

          volume_mount {
            name       = "prometheus-storage"
            mount_path = "/prometheus"
          }

          resources {
            requests = {
              cpu    = var.prometheus_cpu_request
              memory = var.prometheus_memory_request
            }
            limits = {
              cpu    = var.prometheus_cpu_limit
              memory = var.prometheus_memory_limit
            }
          }

          liveness_probe {
            http_get {
              path = "/-/healthy"
              port = 9090
            }
            initial_delay_seconds = 30
            timeout_seconds       = 30
          }

          readiness_probe {
            http_get {
              path = "/-/ready"
              port = 9090
            }
            initial_delay_seconds = 30
            timeout_seconds       = 30
          }
        }

        volume {
          name = "prometheus-config"
          config_map {
            name = kubernetes_config_map.prometheus_config.metadata[0].name
          }
        }

        volume {
          name = "prometheus-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.prometheus.metadata[0].name
          }
        }

        security_context {
          run_as_user     = 65534
          run_as_group    = 65534
          fs_group        = 65534
          run_as_non_root = true
        }
      }
    }
  }

  depends_on = [
    kubernetes_config_map.prometheus_config,
    kubernetes_persistent_volume_claim.prometheus
  ]
}

# Prometheus Service Account
resource "kubernetes_service_account" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  depends_on = [kubernetes_namespace.monitoring]
}

# Prometheus ClusterRole
resource "kubernetes_cluster_role" "prometheus" {
  metadata {
    name = "prometheus"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "nodes/proxy", "services", "endpoints", "pods"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    non_resource_urls = ["/metrics"]
    verbs            = ["get"]
  }
}

# Prometheus ClusterRoleBinding
resource "kubernetes_cluster_role_binding" "prometheus" {
  metadata {
    name = "prometheus"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.prometheus.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.prometheus.metadata[0].name
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
}

# Prometheus PersistentVolumeClaim
resource "kubernetes_persistent_volume_claim" "prometheus" {
  metadata {
    name      = "prometheus-storage"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = var.prometheus_storage_size
      }
    }

    storage_class_name = "gp3-encrypted"
  }

  depends_on = [kubernetes_namespace.monitoring]
}

# Prometheus Service
resource "kubernetes_service" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      app = "prometheus"
    }
  }

  spec {
    selector = {
      app = "prometheus"
    }

    port {
      name        = "web"
      port        = 9090
      target_port = 9090
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.prometheus]
}

# Grafana Deployment
resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      app = "grafana"
      environment = var.environment
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "grafana"
      }
    }

    template {
      metadata {
        labels = {
          app = "grafana"
          environment = var.environment
        }
      }

      spec {
        container {
          name  = "grafana"
          image = "grafana/grafana:${var.grafana_version}"

          port {
            container_port = 3000
            name          = "web"
          }

          env {
            name  = "GF_SECURITY_ADMIN_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.grafana_admin.metadata[0].name
                key  = "password"
              }
            }
          }

          env {
            name  = "GF_INSTALL_PLUGINS"
            value = "grafana-piechart-panel,grafana-worldmap-panel"
          }

          volume_mount {
            name       = "grafana-storage"
            mount_path = "/var/lib/grafana"
          }

          volume_mount {
            name       = "grafana-config"
            mount_path = "/etc/grafana"
          }

          resources {
            requests = {
              cpu    = var.grafana_cpu_request
              memory = var.grafana_memory_request
            }
            limits = {
              cpu    = var.grafana_cpu_limit
              memory = var.grafana_memory_limit
            }
          }

          liveness_probe {
            http_get {
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 30
            timeout_seconds       = 30
          }

          readiness_probe {
            http_get {
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 30
            timeout_seconds       = 30
          }
        }

        volume {
          name = "grafana-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.grafana.metadata[0].name
          }
        }

        volume {
          name = "grafana-config"
          config_map {
            name = kubernetes_config_map.grafana_config.metadata[0].name
          }
        }

        security_context {
          run_as_user     = 472
          run_as_group    = 472
          fs_group        = 472
          run_as_non_root = true
        }
      }
    }
  }

  depends_on = [
    kubernetes_secret.grafana_admin,
    kubernetes_config_map.grafana_config,
    kubernetes_persistent_volume_claim.grafana
  ]
}

# Grafana Secret for Admin Password
resource "kubernetes_secret" "grafana_admin" {
  metadata {
    name      = "grafana-admin"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    password = base64encode(var.grafana_admin_password)
  }

  type = "Opaque"

  depends_on = [kubernetes_namespace.monitoring]
}

# Grafana ConfigMap
resource "kubernetes_config_map" "grafana_config" {
  metadata {
    name      = "grafana-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "grafana.ini" = templatefile("${path.module}/config/grafana.ini", {
      environment = var.environment
    })
    "datasources.yml" = templatefile("${path.module}/config/grafana_datasources.yml", {
      prometheus_url = "http://prometheus:9090"
    })
  }

  depends_on = [kubernetes_namespace.monitoring]
}

# Grafana PersistentVolumeClaim
resource "kubernetes_persistent_volume_claim" "grafana" {
  metadata {
    name      = "grafana-storage"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = var.grafana_storage_size
      }
    }

    storage_class_name = "gp3-encrypted"
  }

  depends_on = [kubernetes_namespace.monitoring]
}

# Grafana Service
resource "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      app = "grafana"
    }
  }

  spec {
    selector = {
      app = "grafana"
    }

    port {
      name        = "web"
      port        = 3000
      target_port = 3000
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.grafana]
}

# Alertmanager Deployment
resource "kubernetes_deployment" "alertmanager" {
  metadata {
    name      = "alertmanager"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      app = "alertmanager"
      environment = var.environment
    }
  }

  spec {
    replicas = var.alertmanager_replicas

    selector {
      match_labels = {
        app = "alertmanager"
      }
    }

    template {
      metadata {
        labels = {
          app = "alertmanager"
          environment = var.environment
        }
      }

      spec {
        container {
          name  = "alertmanager"
          image = "prom/alertmanager:${var.alertmanager_version}"

          port {
            container_port = 9093
            name          = "web"
          }

          args = [
            "--config.file=/etc/alertmanager/alertmanager.yml",
            "--storage.path=/alertmanager",
            "--web.external-url=http://alertmanager:9093"
          ]

          volume_mount {
            name       = "alertmanager-config"
            mount_path = "/etc/alertmanager"
          }

          volume_mount {
            name       = "alertmanager-storage"
            mount_path = "/alertmanager"
          }

          resources {
            requests = {
              cpu    = var.alertmanager_cpu_request
              memory = var.alertmanager_memory_request
            }
            limits = {
              cpu    = var.alertmanager_cpu_limit
              memory = var.alertmanager_memory_limit
            }
          }

          liveness_probe {
            http_get {
              path = "/-/healthy"
              port = 9093
            }
            initial_delay_seconds = 30
            timeout_seconds       = 30
          }

          readiness_probe {
            http_get {
              path = "/-/ready"
              port = 9093
            }
            initial_delay_seconds = 30
            timeout_seconds       = 30
          }
        }

        volume {
          name = "alertmanager-config"
          config_map {
            name = kubernetes_config_map.alertmanager_config.metadata[0].name
          }
        }

        volume {
          name = "alertmanager-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.alertmanager.metadata[0].name
          }
        }

        security_context {
          run_as_user     = 65534
          run_as_group    = 65534
          fs_group        = 65534
          run_as_non_root = true
        }
      }
    }
  }

  depends_on = [
    kubernetes_config_map.alertmanager_config,
    kubernetes_persistent_volume_claim.alertmanager
  ]
}

# Alertmanager ConfigMap
resource "kubernetes_config_map" "alertmanager_config" {
  metadata {
    name      = "alertmanager-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "alertmanager.yml" = templatefile("${path.module}/config/alertmanager.yml", {
      environment = var.environment
      sns_topic_arn = var.sns_topic_arn
      slack_webhook_url = var.slack_webhook_url
    })
  }

  depends_on = [kubernetes_namespace.monitoring]
}

# Alertmanager PersistentVolumeClaim
resource "kubernetes_persistent_volume_claim" "alertmanager" {
  metadata {
    name      = "alertmanager-storage"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = var.alertmanager_storage_size
      }
    }

    storage_class_name = "gp3-encrypted"
  }

  depends_on = [kubernetes_namespace.monitoring]
}

# Alertmanager Service
resource "kubernetes_service" "alertmanager" {
  metadata {
    name      = "alertmanager"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      app = "alertmanager"
    }
  }

  spec {
    selector = {
      app = "alertmanager"
    }

    port {
      name        = "web"
      port        = 9093
      target_port = 9093
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.alertmanager]
}
