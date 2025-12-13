# Comprehensive IAM Roles and Policies for Financial-Grade Security
# Implements least privilege access with detailed audit trails

# Data source for current AWS account
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# EKS Cluster Service Role
resource "aws_iam_role" "eks_cluster" {
  name = "${var.environment}-QuantumBallot-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-QuantumBallot-eks-cluster-role"
    Environment = var.environment
    Service = "eks"
  })
}

# EKS Cluster Policy Attachments
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster.name
}

# EKS Node Group Role
resource "aws_iam_role" "eks_node_group" {
  name = "${var.environment}-QuantumBallot-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-QuantumBallot-eks-node-group-role"
    Environment = var.environment
    Service = "eks"
  })
}

# EKS Node Group Policy Attachments
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}

# Application Service Role
resource "aws_iam_role" "application" {
  name = "${var.environment}-QuantumBallot-application-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.application_external_id
          }
        }
      }
    ]
  })

  max_session_duration = 3600  # 1 hour

  tags = merge(var.common_tags, {
    Name = "${var.environment}-QuantumBallot-application-role"
    Environment = var.environment
    Service = "application"
  })
}

# Application Role Custom Policy
resource "aws_iam_role_policy" "application_policy" {
  name = "${var.environment}-QuantumBallot-application-policy"
  role = aws_iam_role.application.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.environment}-QuantumBallot-app-data/*",
          "arn:aws:s3:::${var.environment}-QuantumBallot-uploads/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.environment}-QuantumBallot-app-data",
          "arn:aws:s3:::${var.environment}-QuantumBallot-uploads"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.environment}/QuantumBallot/database/*",
          "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.environment}/QuantumBallot/api-keys/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = [
          var.kms_key_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/application/${var.environment}-QuantumBallot:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "cloudwatch:namespace" = "QuantumBallot/${var.environment}"
          }
        }
      }
    ]
  })
}

# Database Service Role
resource "aws_iam_role" "database" {
  name = "${var.environment}-QuantumBallot-database-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-QuantumBallot-database-role"
    Environment = var.environment
    Service = "database"
  })
}

# Database Enhanced Monitoring Role
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = "${var.environment}-QuantumBallot-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-QuantumBallot-rds-monitoring-role"
    Environment = var.environment
    Service = "monitoring"
  })
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  role       = aws_iam_role.rds_enhanced_monitoring.name
}

# Lambda Execution Role for Security Functions
resource "aws_iam_role" "lambda_security" {
  name = "${var.environment}-QuantumBallot-lambda-security-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-QuantumBallot-lambda-security-role"
    Environment = var.environment
    Service = "security"
  })
}

# Lambda Security Policy
resource "aws_iam_role_policy" "lambda_security_policy" {
  name = "${var.environment}-QuantumBallot-lambda-security-policy"
  role = aws_iam_role.lambda_security.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "wafv2:GetWebACL",
          "wafv2:UpdateWebACL",
          "wafv2:GetIPSet",
          "wafv2:UpdateIPSet"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = var.security_sns_topic_arn
      }
    ]
  })
}

# CloudWatch Events Role for Security Automation
resource "aws_iam_role" "cloudwatch_events" {
  name = "${var.environment}-QuantumBallot-events-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-QuantumBallot-events-role"
    Environment = var.environment
    Service = "automation"
  })
}

# CloudWatch Events Policy
resource "aws_iam_role_policy" "cloudwatch_events_policy" {
  name = "${var.environment}-QuantumBallot-events-policy"
  role = aws_iam_role.cloudwatch_events.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.environment}-QuantumBallot-security-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = var.security_sns_topic_arn
      }
    ]
  })
}

# Backup Service Role
resource "aws_iam_role" "backup" {
  name = "${var.environment}-QuantumBallot-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-QuantumBallot-backup-role"
    Environment = var.environment
    Service = "backup"
  })
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup.name
}

resource "aws_iam_role_policy_attachment" "backup_restore_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.backup.name
}

# Security Audit Role
resource "aws_iam_role" "security_audit" {
  name = "${var.environment}-QuantumBallot-security-audit-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = var.security_audit_principals
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.security_audit_external_id
          }
          IpAddress = {
            "aws:SourceIp" = var.security_audit_source_ips
          }
        }
      }
    ]
  })

  max_session_duration = 3600  # 1 hour

  tags = merge(var.common_tags, {
    Name = "${var.environment}-QuantumBallot-security-audit-role"
    Environment = var.environment
    Service = "audit"
  })
}

# Security Audit Policy
resource "aws_iam_role_policy" "security_audit_policy" {
  name = "${var.environment}-QuantumBallot-security-audit-policy"
  role = aws_iam_role.security_audit.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudtrail:LookupEvents",
          "cloudtrail:GetTrailStatus",
          "cloudtrail:DescribeTrails"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:FilterLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "config:GetComplianceDetailsByConfigRule",
          "config:GetComplianceDetailsByResource",
          "config:GetConfigRuleEvaluationStatus",
          "config:DescribeConfigRules",
          "config:DescribeConfigurationRecorders",
          "config:DescribeDeliveryChannels"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "guardduty:GetDetector",
          "guardduty:GetFindings",
          "guardduty:ListDetectors",
          "guardduty:ListFindings"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "securityhub:GetFindings",
          "securityhub:GetInsights",
          "securityhub:GetInsightResults"
        ]
        Resource = "*"
      }
    ]
  })
}

# Cross-Account Access Role for Disaster Recovery
resource "aws_iam_role" "cross_account_dr" {
  name = "${var.environment}-QuantumBallot-cross-account-dr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = var.dr_account_principals
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.dr_external_id
          }
        }
      }
    ]
  })

  max_session_duration = 3600  # 1 hour

  tags = merge(var.common_tags, {
    Name = "${var.environment}-QuantumBallot-cross-account-dr-role"
    Environment = var.environment
    Service = "disaster-recovery"
  })
}

# Cross-Account DR Policy
resource "aws_iam_role_policy" "cross_account_dr_policy" {
  name = "${var.environment}-QuantumBallot-cross-account-dr-policy"
  role = aws_iam_role.cross_account_dr.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.environment}-QuantumBallot-backups",
          "arn:aws:s3:::${var.environment}-QuantumBallot-backups/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBSnapshots",
          "rds:CopyDBSnapshot"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = var.kms_key_arn
      }
    ]
  })
}

# Instance Profile for EC2 Instances
resource "aws_iam_instance_profile" "application" {
  name = "${var.environment}-QuantumBallot-application-profile"
  role = aws_iam_role.application.name

  tags = merge(var.common_tags, {
    Name = "${var.environment}-QuantumBallot-application-profile"
    Environment = var.environment
  })
}
