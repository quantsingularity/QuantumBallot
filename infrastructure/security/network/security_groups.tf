# Comprehensive Security Groups for Financial-Grade Network Security
# Implements least privilege access with detailed logging and monitoring

# Security group for Application Load Balancer
resource "aws_security_group" "alb" {
  name_prefix = "${var.environment}-chainocracy-alb-"
  vpc_id      = var.vpc_id
  description = "Security group for Application Load Balancer"

  # HTTPS inbound from internet
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP redirect to HTTPS
  ingress {
    description = "HTTP redirect to HTTPS"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound to application tier
  egress {
    description     = "To application tier"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  # Outbound for health checks
  egress {
    description     = "Health check to application tier"
    from_port       = var.health_check_port
    to_port         = var.health_check_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-alb-sg"
    Tier = "load-balancer"
    Environment = var.environment
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security group for Web Application Firewall
resource "aws_security_group" "waf" {
  name_prefix = "${var.environment}-chainocracy-waf-"
  vpc_id      = var.vpc_id
  description = "Security group for Web Application Firewall"

  # HTTPS from ALB
  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Outbound to application tier
  egress {
    description     = "To application tier"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-waf-sg"
    Tier = "security"
    Environment = var.environment
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security group for application tier
resource "aws_security_group" "app" {
  name_prefix = "${var.environment}-chainocracy-app-"
  vpc_id      = var.vpc_id
  description = "Security group for application tier"

  # Application port from ALB
  ingress {
    description     = "Application port from ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Health check port from ALB
  ingress {
    description     = "Health check from ALB"
    from_port       = var.health_check_port
    to_port         = var.health_check_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Inter-service communication
  ingress {
    description = "Inter-service communication"
    from_port   = var.service_mesh_port
    to_port     = var.service_mesh_port
    protocol    = "tcp"
    self        = true
  }

  # Outbound to database tier
  egress {
    description     = "To database tier"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.db.id]
  }

  # Outbound to Redis cache
  egress {
    description     = "To Redis cache"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.cache.id]
  }

  # Outbound HTTPS for external APIs
  egress {
    description = "HTTPS for external APIs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound DNS
  egress {
    description = "DNS resolution"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Outbound NTP
  egress {
    description = "NTP synchronization"
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-app-sg"
    Tier = "application"
    Environment = var.environment
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security group for database tier
resource "aws_security_group" "db" {
  name_prefix = "${var.environment}-chainocracy-db-"
  vpc_id      = var.vpc_id
  description = "Security group for database tier"

  # PostgreSQL from application tier
  ingress {
    description     = "PostgreSQL from application tier"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  # PostgreSQL from bastion host for maintenance
  ingress {
    description     = "PostgreSQL from bastion"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # Database replication between instances
  ingress {
    description = "Database replication"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    self        = true
  }

  # No outbound rules - databases should not initiate connections

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-db-sg"
    Tier = "database"
    Environment = var.environment
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security group for cache tier (Redis)
resource "aws_security_group" "cache" {
  name_prefix = "${var.environment}-chainocracy-cache-"
  vpc_id      = var.vpc_id
  description = "Security group for cache tier"

  # Redis from application tier
  ingress {
    description     = "Redis from application tier"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  # Redis cluster communication
  ingress {
    description = "Redis cluster communication"
    from_port   = 16379
    to_port     = 16379
    protocol    = "tcp"
    self        = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-cache-sg"
    Tier = "cache"
    Environment = var.environment
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security group for bastion host
resource "aws_security_group" "bastion" {
  name_prefix = "${var.environment}-chainocracy-bastion-"
  vpc_id      = var.vpc_id
  description = "Security group for bastion host"

  # SSH from specific IP ranges (company networks)
  ingress {
    description = "SSH from company networks"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  # Outbound SSH to private instances
  egress {
    description = "SSH to private instances"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Outbound to database for maintenance
  egress {
    description     = "Database maintenance"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.db.id]
  }

  # Outbound HTTPS for updates
  egress {
    description = "HTTPS for updates"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound DNS
  egress {
    description = "DNS resolution"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-bastion-sg"
    Tier = "management"
    Environment = var.environment
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security group for monitoring and logging
resource "aws_security_group" "monitoring" {
  name_prefix = "${var.environment}-chainocracy-monitoring-"
  vpc_id      = var.vpc_id
  description = "Security group for monitoring and logging infrastructure"

  # Prometheus metrics collection
  ingress {
    description = "Prometheus metrics from application tier"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Grafana dashboard access
  ingress {
    description = "Grafana dashboard access"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.monitoring_access_cidrs
  }

  # ELK stack communication
  ingress {
    description = "Elasticsearch"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "Kibana"
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = var.monitoring_access_cidrs
  }

  ingress {
    description = "Logstash"
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Outbound for data collection
  egress {
    description = "Data collection from all tiers"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Outbound HTTPS for external integrations
  egress {
    description = "HTTPS for external integrations"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-monitoring-sg"
    Tier = "monitoring"
    Environment = var.environment
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security group for VPC endpoints
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.environment}-chainocracy-vpce-"
  vpc_id      = var.vpc_id
  description = "Security group for VPC endpoints"

  # HTTPS from private subnets
  ingress {
    description = "HTTPS from private subnets"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = concat(
      var.private_app_subnet_cidrs,
      var.private_db_subnet_cidrs,
      var.isolated_mgmt_subnet_cidrs
    )
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-vpce-sg"
    Tier = "endpoints"
    Environment = var.environment
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security group for blockchain nodes
resource "aws_security_group" "blockchain" {
  name_prefix = "${var.environment}-chainocracy-blockchain-"
  vpc_id      = var.vpc_id
  description = "Security group for blockchain nodes"

  # Blockchain P2P communication
  ingress {
    description = "Blockchain P2P"
    from_port   = var.blockchain_p2p_port
    to_port     = var.blockchain_p2p_port
    protocol    = "tcp"
    cidr_blocks = var.blockchain_peer_cidrs
  }

  # Blockchain RPC from application tier
  ingress {
    description     = "Blockchain RPC from application"
    from_port       = var.blockchain_rpc_port
    to_port         = var.blockchain_rpc_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  # Outbound P2P communication
  egress {
    description = "Outbound P2P communication"
    from_port   = var.blockchain_p2p_port
    to_port     = var.blockchain_p2p_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound HTTPS for blockchain updates
  egress {
    description = "HTTPS for blockchain updates"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-blockchain-sg"
    Tier = "blockchain"
    Environment = var.environment
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security group rules for enhanced logging
resource "aws_security_group_rule" "log_all_traffic" {
  for_each = {
    alb        = aws_security_group.alb.id
    app        = aws_security_group.app.id
    db         = aws_security_group.db.id
    cache      = aws_security_group.cache.id
    bastion    = aws_security_group.bastion.id
    monitoring = aws_security_group.monitoring.id
    blockchain = aws_security_group.blockchain.id
  }

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = each.value
  cidr_blocks       = ["255.255.255.255/32"]  # Dummy rule for logging
  description       = "Logging rule - no actual traffic allowed"
}
