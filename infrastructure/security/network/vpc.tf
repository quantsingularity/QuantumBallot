# Enhanced VPC Configuration for Financial-Grade Security
# Implements defense-in-depth network security with comprehensive monitoring

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data sources for availability zones and current region
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}

# Main VPC with enhanced security features
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Enhanced security features
  enable_network_address_usage_metrics = true

  tags = merge(var.common_tags, {
    Name                = "${var.environment}-chainocracy-vpc"
    Environment         = var.environment
    SecurityLevel       = "high"
    ComplianceRequired  = "true"
    DataClassification  = "sensitive"
  })
}

# Internet Gateway with enhanced monitoring
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-igw"
    Environment = var.environment
  })
}

# Public subnets for load balancers and NAT gateways
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false  # Enhanced security - no auto-assign public IPs

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-public-${count.index + 1}"
    Type = "public"
    Environment = var.environment
    Tier = "dmz"
  })
}

# Private subnets for application tier
resource "aws_subnet" "private_app" {
  count = length(var.private_app_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-private-app-${count.index + 1}"
    Type = "private"
    Tier = "application"
    Environment = var.environment
  })
}

# Private subnets for database tier
resource "aws_subnet" "private_db" {
  count = length(var.private_db_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-private-db-${count.index + 1}"
    Type = "private"
    Tier = "database"
    Environment = var.environment
  })
}

# Isolated subnets for management and monitoring
resource "aws_subnet" "isolated_mgmt" {
  count = length(var.isolated_mgmt_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.isolated_mgmt_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-isolated-mgmt-${count.index + 1}"
    Type = "isolated"
    Tier = "management"
    Environment = var.environment
  })
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = length(aws_subnet.public)

  domain = "vpc"

  depends_on = [aws_internet_gateway.main]

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-nat-eip-${count.index + 1}"
    Environment = var.environment
  })
}

# NAT Gateways for outbound internet access from private subnets
resource "aws_nat_gateway" "main" {
  count = length(aws_subnet.public)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-nat-${count.index + 1}"
    Environment = var.environment
  })

  depends_on = [aws_internet_gateway.main]
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-public-rt"
    Type = "public"
    Environment = var.environment
  })
}

# Route tables for private application subnets
resource "aws_route_table" "private_app" {
  count = length(aws_subnet.private_app)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-private-app-rt-${count.index + 1}"
    Type = "private"
    Tier = "application"
    Environment = var.environment
  })
}

# Route tables for private database subnets (no internet access)
resource "aws_route_table" "private_db" {
  count = length(aws_subnet.private_db)

  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-private-db-rt-${count.index + 1}"
    Type = "private"
    Tier = "database"
    Environment = var.environment
  })
}

# Route tables for isolated management subnets
resource "aws_route_table" "isolated_mgmt" {
  count = length(aws_subnet.isolated_mgmt)

  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-isolated-mgmt-rt-${count.index + 1}"
    Type = "isolated"
    Tier = "management"
    Environment = var.environment
  })
}

# Route table associations
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_app" {
  count = length(aws_subnet.private_app)

  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app[count.index].id
}

resource "aws_route_table_association" "private_db" {
  count = length(aws_subnet.private_db)

  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db[count.index].id
}

resource "aws_route_table_association" "isolated_mgmt" {
  count = length(aws_subnet.isolated_mgmt)

  subnet_id      = aws_subnet.isolated_mgmt[count.index].id
  route_table_id = aws_route_table.isolated_mgmt[count.index].id
}

# VPC Flow Logs for comprehensive network monitoring
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.flow_log.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  log_format = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${windowstart} $${windowend} $${action} $${flowlogstatus} $${vpc-id} $${subnet-id} $${instance-id} $${tcp-flags} $${type} $${pkt-srcaddr} $${pkt-dstaddr} $${region} $${az-id} $${sublocation-type} $${sublocation-id}"

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-vpc-flow-log"
    Environment = var.environment
  })
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name              = "/aws/vpc/flowlogs/${var.environment}-chainocracy"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-vpc-flow-log-group"
    Environment = var.environment
  })
}

# IAM role for VPC Flow Logs
resource "aws_iam_role" "flow_log" {
  name = "${var.environment}-chainocracy-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-flow-log-role"
    Environment = var.environment
  })
}

# IAM policy for VPC Flow Logs
resource "aws_iam_role_policy" "flow_log" {
  name = "${var.environment}-chainocracy-flow-log-policy"
  role = aws_iam_role.flow_log.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

# KMS key for log encryption
resource "aws_kms_key" "logs" {
  description             = "KMS key for ${var.environment} Chainocracy log encryption"
  deletion_window_in_days = var.kms_deletion_window
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-logs-kms-key"
    Environment = var.environment
  })
}

# KMS key alias
resource "aws_kms_alias" "logs" {
  name          = "alias/${var.environment}-chainocracy-logs"
  target_key_id = aws_kms_key.logs.key_id
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# VPC Endpoint for S3 (Gateway endpoint)
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"

  route_table_ids = concat(
    [aws_route_table.public.id],
    aws_route_table.private_app[*].id,
    aws_route_table.private_db[*].id,
    aws_route_table.isolated_mgmt[*].id
  )

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.environment}-chainocracy-*",
          "arn:aws:s3:::${var.environment}-chainocracy-*/*"
        ]
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-s3-endpoint"
    Environment = var.environment
  })
}

# VPC Endpoint for DynamoDB (Gateway endpoint)
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.dynamodb"

  route_table_ids = concat(
    [aws_route_table.public.id],
    aws_route_table.private_app[*].id,
    aws_route_table.private_db[*].id,
    aws_route_table.isolated_mgmt[*].id
  )

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-dynamodb-endpoint"
    Environment = var.environment
  })
}
