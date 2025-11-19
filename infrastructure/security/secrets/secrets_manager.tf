# Comprehensive Secrets Management for Financial-Grade Security
# Implements secure storage and rotation of sensitive credentials

# Database Master Password Secret
resource "aws_secretsmanager_secret" "database_master_password" {
  name                    = "${var.environment}/chainocracy/database/master-password"
  description             = "Master password for ${var.environment} Chainocracy database"
  kms_key_id             = var.kms_secrets_key_id
  recovery_window_in_days = var.secret_recovery_window

  replica {
    region     = var.replica_region
    kms_key_id = var.replica_kms_key_id
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-db-master-password"
    Environment = var.environment
    SecretType = "database-credential"
  })
}

# Database Master Password Secret Version
resource "aws_secretsmanager_secret_version" "database_master_password" {
  secret_id = aws_secretsmanager_secret.database_master_password.id
  secret_string = jsonencode({
    username = var.database_master_username
    password = random_password.database_master_password.result
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Random Password for Database Master User
resource "random_password" "database_master_password" {
  length  = 32
  special = true
  upper   = true
  lower   = true
  numeric = true
}

# Database Application User Secret
resource "aws_secretsmanager_secret" "database_app_user" {
  name                    = "${var.environment}/chainocracy/database/app-user"
  description             = "Application user credentials for ${var.environment} Chainocracy database"
  kms_key_id             = var.kms_secrets_key_id
  recovery_window_in_days = var.secret_recovery_window

  replica {
    region     = var.replica_region
    kms_key_id = var.replica_kms_key_id
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-db-app-user"
    Environment = var.environment
    SecretType = "database-credential"
  })
}

# Database Application User Secret Version
resource "aws_secretsmanager_secret_version" "database_app_user" {
  secret_id = aws_secretsmanager_secret.database_app_user.id
  secret_string = jsonencode({
    username = var.database_app_username
    password = random_password.database_app_password.result
    host     = var.database_endpoint
    port     = var.database_port
    dbname   = var.database_name
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Random Password for Database Application User
resource "random_password" "database_app_password" {
  length  = 32
  special = true
  upper   = true
  lower   = true
  numeric = true
}

# Redis Authentication Token Secret
resource "aws_secretsmanager_secret" "redis_auth_token" {
  name                    = "${var.environment}/chainocracy/redis/auth-token"
  description             = "Redis authentication token for ${var.environment} Chainocracy"
  kms_key_id             = var.kms_secrets_key_id
  recovery_window_in_days = var.secret_recovery_window

  replica {
    region     = var.replica_region
    kms_key_id = var.replica_kms_key_id
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-redis-auth-token"
    Environment = var.environment
    SecretType = "cache-credential"
  })
}

# Redis Authentication Token Secret Version
resource "aws_secretsmanager_secret_version" "redis_auth_token" {
  secret_id = aws_secretsmanager_secret.redis_auth_token.id
  secret_string = jsonencode({
    auth_token = random_password.redis_auth_token.result
    endpoint   = var.redis_endpoint
    port       = var.redis_port
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Random Password for Redis Authentication
resource "random_password" "redis_auth_token" {
  length  = 64
  special = false  # Redis auth tokens typically don't use special characters
  upper   = true
  lower   = true
  numeric = true
}

# JWT Secret Key
resource "aws_secretsmanager_secret" "jwt_secret" {
  name                    = "${var.environment}/chainocracy/api-keys/jwt-secret"
  description             = "JWT secret key for ${var.environment} Chainocracy application"
  kms_key_id             = var.kms_secrets_key_id
  recovery_window_in_days = var.secret_recovery_window

  replica {
    region     = var.replica_region
    kms_key_id = var.replica_kms_key_id
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-jwt-secret"
    Environment = var.environment
    SecretType = "api-key"
  })
}

# JWT Secret Key Version
resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id = aws_secretsmanager_secret.jwt_secret.id
  secret_string = jsonencode({
    secret_key = random_password.jwt_secret.result
    algorithm  = "HS256"
    expires_in = "3600"
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Random Password for JWT Secret
resource "random_password" "jwt_secret" {
  length  = 64
  special = true
  upper   = true
  lower   = true
  numeric = true
}

# Blockchain Node Private Key
resource "aws_secretsmanager_secret" "blockchain_private_key" {
  name                    = "${var.environment}/chainocracy/blockchain/private-key"
  description             = "Blockchain node private key for ${var.environment} Chainocracy"
  kms_key_id             = var.kms_secrets_key_id
  recovery_window_in_days = var.secret_recovery_window

  replica {
    region     = var.replica_region
    kms_key_id = var.replica_kms_key_id
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-blockchain-private-key"
    Environment = var.environment
    SecretType = "blockchain-credential"
  })
}

# Blockchain Node Private Key Version
resource "aws_secretsmanager_secret_version" "blockchain_private_key" {
  secret_id = aws_secretsmanager_secret.blockchain_private_key.id
  secret_string = jsonencode({
    private_key = var.blockchain_private_key
    public_key  = var.blockchain_public_key
    address     = var.blockchain_address
    network     = var.blockchain_network
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# API Gateway API Key
resource "aws_secretsmanager_secret" "api_gateway_key" {
  name                    = "${var.environment}/chainocracy/api-keys/gateway-key"
  description             = "API Gateway key for ${var.environment} Chainocracy"
  kms_key_id             = var.kms_secrets_key_id
  recovery_window_in_days = var.secret_recovery_window

  replica {
    region     = var.replica_region
    kms_key_id = var.replica_kms_key_id
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-api-gateway-key"
    Environment = var.environment
    SecretType = "api-key"
  })
}

# API Gateway Key Version
resource "aws_secretsmanager_secret_version" "api_gateway_key" {
  secret_id = aws_secretsmanager_secret.api_gateway_key.id
  secret_string = jsonencode({
    api_key    = random_password.api_gateway_key.result
    key_name   = "${var.environment}-chainocracy-api-key"
    usage_plan = "${var.environment}-chainocracy-usage-plan"
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Random Password for API Gateway Key
resource "random_password" "api_gateway_key" {
  length  = 40
  special = false
  upper   = true
  lower   = true
  numeric = true
}

# Third-Party Service API Keys
resource "aws_secretsmanager_secret" "third_party_apis" {
  name                    = "${var.environment}/chainocracy/api-keys/third-party"
  description             = "Third-party service API keys for ${var.environment} Chainocracy"
  kms_key_id             = var.kms_secrets_key_id
  recovery_window_in_days = var.secret_recovery_window

  replica {
    region     = var.replica_region
    kms_key_id = var.replica_kms_key_id
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-third-party-apis"
    Environment = var.environment
    SecretType = "api-key"
  })
}

# Third-Party APIs Secret Version
resource "aws_secretsmanager_secret_version" "third_party_apis" {
  secret_id = aws_secretsmanager_secret.third_party_apis.id
  secret_string = jsonencode({
    sendgrid_api_key     = var.sendgrid_api_key
    twilio_account_sid   = var.twilio_account_sid
    twilio_auth_token    = var.twilio_auth_token
    stripe_secret_key    = var.stripe_secret_key
    stripe_webhook_secret = var.stripe_webhook_secret
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# SSL/TLS Certificate Private Key
resource "aws_secretsmanager_secret" "ssl_private_key" {
  name                    = "${var.environment}/chainocracy/ssl/private-key"
  description             = "SSL/TLS certificate private key for ${var.environment} Chainocracy"
  kms_key_id             = var.kms_secrets_key_id
  recovery_window_in_days = var.secret_recovery_window

  replica {
    region     = var.replica_region
    kms_key_id = var.replica_kms_key_id
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-ssl-private-key"
    Environment = var.environment
    SecretType = "ssl-certificate"
  })
}

# SSL Private Key Version
resource "aws_secretsmanager_secret_version" "ssl_private_key" {
  secret_id = aws_secretsmanager_secret.ssl_private_key.id
  secret_string = jsonencode({
    private_key  = var.ssl_private_key
    certificate  = var.ssl_certificate
    ca_bundle    = var.ssl_ca_bundle
    domain_name  = var.domain_name
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Automatic Secret Rotation for Database Credentials
resource "aws_secretsmanager_secret_rotation" "database_master_password" {
  secret_id           = aws_secretsmanager_secret.database_master_password.id
  rotation_lambda_arn = aws_lambda_function.secret_rotation.arn

  rotation_rules {
    automatically_after_days = var.password_rotation_days
  }

  depends_on = [aws_lambda_permission.secret_rotation]
}

resource "aws_secretsmanager_secret_rotation" "database_app_user" {
  secret_id           = aws_secretsmanager_secret.database_app_user.id
  rotation_lambda_arn = aws_lambda_function.secret_rotation.arn

  rotation_rules {
    automatically_after_days = var.password_rotation_days
  }

  depends_on = [aws_lambda_permission.secret_rotation]
}

# Lambda Function for Secret Rotation
resource "aws_lambda_function" "secret_rotation" {
  filename         = "secret_rotation.zip"
  function_name    = "${var.environment}-chainocracy-secret-rotation"
  role            = var.lambda_execution_role_arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.secret_rotation_zip.output_base64sha256
  runtime         = "python3.9"
  timeout         = 300

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${var.aws_region}.amazonaws.com"
      RDS_ENDPOINT            = var.database_endpoint
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-secret-rotation"
    Environment = var.environment
  })
}

# Archive file for Lambda function
data "archive_file" "secret_rotation_zip" {
  type        = "zip"
  output_path = "secret_rotation.zip"
  source {
    content = templatefile("${path.module}/lambda/secret_rotation.py", {
      environment = var.environment
    })
    filename = "lambda_function.py"
  }
}

# Lambda Permission for Secrets Manager
resource "aws_lambda_permission" "secret_rotation" {
  statement_id  = "AllowExecutionFromSecretsManager"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.secret_rotation.function_name
  principal     = "secretsmanager.amazonaws.com"
}

# CloudWatch Log Group for Secret Rotation Lambda
resource "aws_cloudwatch_log_group" "secret_rotation" {
  name              = "/aws/lambda/${aws_lambda_function.secret_rotation.function_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_logs_key_id

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-secret-rotation-logs"
    Environment = var.environment
  })
}

# CloudWatch Alarms for Secret Access
resource "aws_cloudwatch_metric_alarm" "secret_access_anomaly" {
  for_each = {
    database_master = aws_secretsmanager_secret.database_master_password.name
    database_app    = aws_secretsmanager_secret.database_app_user.name
    jwt_secret      = aws_secretsmanager_secret.jwt_secret.name
    blockchain_key  = aws_secretsmanager_secret.blockchain_private_key.name
  }

  alarm_name          = "${var.environment}-chainocracy-secret-access-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "SuccessfulRequestLatency"
  namespace           = "AWS/SecretsManager"
  period              = "300"
  statistic           = "Average"
  threshold           = var.secret_access_threshold
  alarm_description   = "This metric monitors unusual secret access patterns for ${each.key}"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    SecretName = each.value
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-secret-access-${each.key}-alarm"
    Environment = var.environment
  })
}

# Secret Access Policy for Application Role
resource "aws_iam_policy" "secret_access" {
  name        = "${var.environment}-chainocracy-secret-access-policy"
  description = "Policy for accessing Chainocracy secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          aws_secretsmanager_secret.database_app_user.arn,
          aws_secretsmanager_secret.redis_auth_token.arn,
          aws_secretsmanager_secret.jwt_secret.arn,
          aws_secretsmanager_secret.api_gateway_key.arn,
          aws_secretsmanager_secret.third_party_apis.arn
        ]
        Condition = {
          StringEquals = {
            "secretsmanager:ResourceTag/Environment" = var.environment
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = var.kms_secrets_key_arn
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${var.aws_region}.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-secret-access-policy"
    Environment = var.environment
  })
}
