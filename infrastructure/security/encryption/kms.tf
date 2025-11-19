# Comprehensive KMS Key Management for Financial-Grade Encryption
# Implements encryption at rest and in transit with proper key rotation

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Primary KMS Key for Application Data
resource "aws_kms_key" "application_data" {
  description             = "KMS key for ${var.environment} Chainocracy application data encryption"
  deletion_window_in_days = var.kms_deletion_window
  enable_key_rotation     = true
  multi_region           = var.enable_multi_region_keys

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
        Sid    = "Allow Application Role"
        Effect = "Allow"
        Principal = {
          AWS = var.application_role_arn
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow Database Service"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow S3 Service"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
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
      },
      {
        Sid    = "Allow EBS Service"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "ec2.${data.aws_region.current.name}.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-application-data-key"
    Environment = var.environment
    Purpose = "application-data"
  })
}

# KMS Key Alias for Application Data
resource "aws_kms_alias" "application_data" {
  name          = "alias/${var.environment}-chainocracy-application-data"
  target_key_id = aws_kms_key.application_data.key_id
}

# KMS Key for Database Encryption
resource "aws_kms_key" "database" {
  description             = "KMS key for ${var.environment} Chainocracy database encryption"
  deletion_window_in_days = var.kms_deletion_window
  enable_key_rotation     = true
  multi_region           = var.enable_multi_region_keys

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
        Sid    = "Allow RDS Service"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow Database Role"
        Effect = "Allow"
        Principal = {
          AWS = var.database_role_arn
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow Backup Service"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-database-key"
    Environment = var.environment
    Purpose = "database"
  })
}

# KMS Key Alias for Database
resource "aws_kms_alias" "database" {
  name          = "alias/${var.environment}-chainocracy-database"
  target_key_id = aws_kms_key.database.key_id
}

# KMS Key for Secrets Manager
resource "aws_kms_key" "secrets" {
  description             = "KMS key for ${var.environment} Chainocracy secrets encryption"
  deletion_window_in_days = var.kms_deletion_window
  enable_key_rotation     = true
  multi_region           = var.enable_multi_region_keys

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
        Sid    = "Allow Secrets Manager"
        Effect = "Allow"
        Principal = {
          Service = "secretsmanager.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow Application Role"
        Effect = "Allow"
        Principal = {
          AWS = var.application_role_arn
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-secrets-key"
    Environment = var.environment
    Purpose = "secrets"
  })
}

# KMS Key Alias for Secrets
resource "aws_kms_alias" "secrets" {
  name          = "alias/${var.environment}-chainocracy-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}

# KMS Key for S3 Bucket Encryption
resource "aws_kms_key" "s3" {
  description             = "KMS key for ${var.environment} Chainocracy S3 bucket encryption"
  deletion_window_in_days = var.kms_deletion_window
  enable_key_rotation     = true
  multi_region           = var.enable_multi_region_keys

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
        Sid    = "Allow S3 Service"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow Application Role"
        Effect = "Allow"
        Principal = {
          AWS = var.application_role_arn
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow CloudTrail"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
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
    Name = "${var.environment}-chainocracy-s3-key"
    Environment = var.environment
    Purpose = "s3"
  })
}

# KMS Key Alias for S3
resource "aws_kms_alias" "s3" {
  name          = "alias/${var.environment}-chainocracy-s3"
  target_key_id = aws_kms_key.s3.key_id
}

# KMS Key for EBS Volume Encryption
resource "aws_kms_key" "ebs" {
  description             = "KMS key for ${var.environment} Chainocracy EBS volume encryption"
  deletion_window_in_days = var.kms_deletion_window
  enable_key_rotation     = true
  multi_region           = var.enable_multi_region_keys

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
        Sid    = "Allow EC2 Service"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "ec2.${data.aws_region.current.name}.amazonaws.com"
          }
        }
      },
      {
        Sid    = "Allow Auto Scaling"
        Effect = "Allow"
        Principal = {
          Service = "autoscaling.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-ebs-key"
    Environment = var.environment
    Purpose = "ebs"
  })
}

# KMS Key Alias for EBS
resource "aws_kms_alias" "ebs" {
  name          = "alias/${var.environment}-chainocracy-ebs"
  target_key_id = aws_kms_key.ebs.key_id
}

# KMS Key for CloudWatch Logs
resource "aws_kms_key" "logs" {
  description             = "KMS key for ${var.environment} Chainocracy CloudWatch logs encryption"
  deletion_window_in_days = var.kms_deletion_window
  enable_key_rotation     = true
  multi_region           = var.enable_multi_region_keys

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
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/*"
          }
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-logs-key"
    Environment = var.environment
    Purpose = "logs"
  })
}

# KMS Key Alias for Logs
resource "aws_kms_alias" "logs" {
  name          = "alias/${var.environment}-chainocracy-logs"
  target_key_id = aws_kms_key.logs.key_id
}

# KMS Key for SNS Topic Encryption
resource "aws_kms_key" "sns" {
  description             = "KMS key for ${var.environment} Chainocracy SNS topic encryption"
  deletion_window_in_days = var.kms_deletion_window
  enable_key_rotation     = true
  multi_region           = var.enable_multi_region_keys

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
        Sid    = "Allow SNS Service"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Events"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
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
    Name = "${var.environment}-chainocracy-sns-key"
    Environment = var.environment
    Purpose = "sns"
  })
}

# KMS Key Alias for SNS
resource "aws_kms_alias" "sns" {
  name          = "alias/${var.environment}-chainocracy-sns"
  target_key_id = aws_kms_key.sns.key_id
}

# CloudWatch Alarms for KMS Key Usage
resource "aws_cloudwatch_metric_alarm" "kms_key_usage" {
  for_each = {
    application_data = aws_kms_key.application_data.key_id
    database        = aws_kms_key.database.key_id
    secrets         = aws_kms_key.secrets.key_id
    s3              = aws_kms_key.s3.key_id
    ebs             = aws_kms_key.ebs.key_id
    logs            = aws_kms_key.logs.key_id
    sns             = aws_kms_key.sns.key_id
  }

  alarm_name          = "${var.environment}-chainocracy-kms-${each.key}-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "NumberOfRequestsExceeded"
  namespace           = "AWS/KMS"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.kms_usage_threshold
  alarm_description   = "This metric monitors KMS key usage for ${each.key}"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    KeyId = each.value
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-kms-${each.key}-usage-alarm"
    Environment = var.environment
  })
}

# KMS Key Grants for Cross-Service Access
resource "aws_kms_grant" "rds_grant" {
  name              = "${var.environment}-chainocracy-rds-grant"
  key_id            = aws_kms_key.database.key_id
  grantee_principal = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"
  operations        = ["Encrypt", "Decrypt", "ReEncryptFrom", "ReEncryptTo", "GenerateDataKey", "GenerateDataKeyWithoutPlaintext", "DescribeKey", "CreateGrant"]

  constraints {
    encryption_context_equals = {
      "aws:rds:db-cluster-id" = "${var.environment}-chainocracy-cluster"
    }
  }
}

resource "aws_kms_grant" "backup_grant" {
  name              = "${var.environment}-chainocracy-backup-grant"
  key_id            = aws_kms_key.database.key_id
  grantee_principal = aws_iam_role.backup_role.arn
  operations        = ["Encrypt", "Decrypt", "ReEncryptFrom", "ReEncryptTo", "GenerateDataKey", "GenerateDataKeyWithoutPlaintext", "DescribeKey", "CreateGrant"]

  constraints {
    encryption_context_subset = {
      "aws:backup:source-resource" = "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster:${var.environment}-chainocracy-cluster"
    }
  }
}
