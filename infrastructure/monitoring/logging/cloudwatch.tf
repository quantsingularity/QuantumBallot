# Comprehensive CloudWatch Logging for Financial-Grade Monitoring
# Implements centralized logging with encryption and long-term retention

# CloudWatch Log Groups for Application Components
resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/application/${var.environment}-chainocracy"
  retention_in_days = var.application_log_retention_days
  kms_key_id        = var.kms_logs_key_id

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-application-logs"
    Environment = var.environment
    LogType = "application"
  })
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.environment}-chainocracy"
  retention_in_days = var.api_log_retention_days
  kms_key_id        = var.kms_logs_key_id

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-api-gateway-logs"
    Environment = var.environment
    LogType = "api-gateway"
  })
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.environment}-chainocracy"
  retention_in_days = var.lambda_log_retention_days
  kms_key_id        = var.kms_logs_key_id

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-lambda-logs"
    Environment = var.environment
    LogType = "lambda"
  })
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/aws/ecs/${var.environment}-chainocracy"
  retention_in_days = var.ecs_log_retention_days
  kms_key_id        = var.kms_logs_key_id

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-ecs-logs"
    Environment = var.environment
    LogType = "ecs"
  })
}

resource "aws_cloudwatch_log_group" "rds" {
  name              = "/aws/rds/instance/${var.environment}-chainocracy/postgresql"
  retention_in_days = var.database_log_retention_days
  kms_key_id        = var.kms_logs_key_id

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-rds-logs"
    Environment = var.environment
    LogType = "database"
  })
}

resource "aws_cloudwatch_log_group" "security" {
  name              = "/aws/security/${var.environment}-chainocracy"
  retention_in_days = var.security_log_retention_days
  kms_key_id        = var.kms_logs_key_id

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-security-logs"
    Environment = var.environment
    LogType = "security"
  })
}

resource "aws_cloudwatch_log_group" "audit" {
  name              = "/aws/audit/${var.environment}-chainocracy"
  retention_in_days = var.audit_log_retention_days
  kms_key_id        = var.kms_logs_key_id

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-audit-logs"
    Environment = var.environment
    LogType = "audit"
  })
}

# CloudWatch Log Streams for Different Components
resource "aws_cloudwatch_log_stream" "application_backend" {
  name           = "backend"
  log_group_name = aws_cloudwatch_log_group.application.name
}

resource "aws_cloudwatch_log_stream" "application_frontend" {
  name           = "frontend"
  log_group_name = aws_cloudwatch_log_group.application.name
}

resource "aws_cloudwatch_log_stream" "application_blockchain" {
  name           = "blockchain"
  log_group_name = aws_cloudwatch_log_group.application.name
}

# CloudWatch Log Metric Filters for Security Events
resource "aws_cloudwatch_log_metric_filter" "failed_logins" {
  name           = "${var.environment}-chainocracy-failed-logins"
  log_group_name = aws_cloudwatch_log_group.application.name
  pattern        = "[timestamp, request_id, level=\"ERROR\", message=\"Authentication failed*\"]"

  metric_transformation {
    name      = "FailedLogins"
    namespace = "Chainocracy/${var.environment}/Security"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "suspicious_activity" {
  name           = "${var.environment}-chainocracy-suspicious-activity"
  log_group_name = aws_cloudwatch_log_group.security.name
  pattern        = "[timestamp, request_id, level=\"WARN\", message=\"Suspicious activity detected*\"]"

  metric_transformation {
    name      = "SuspiciousActivity"
    namespace = "Chainocracy/${var.environment}/Security"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "privilege_escalation" {
  name           = "${var.environment}-chainocracy-privilege-escalation"
  log_group_name = aws_cloudwatch_log_group.audit.name
  pattern        = "[timestamp, user, action=\"PRIVILEGE_ESCALATION\", resource, result]"

  metric_transformation {
    name      = "PrivilegeEscalation"
    namespace = "Chainocracy/${var.environment}/Security"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "data_access_violations" {
  name           = "${var.environment}-chainocracy-data-access-violations"
  log_group_name = aws_cloudwatch_log_group.audit.name
  pattern        = "[timestamp, user, action=\"DATA_ACCESS\", resource, result=\"DENIED\"]"

  metric_transformation {
    name      = "DataAccessViolations"
    namespace = "Chainocracy/${var.environment}/Security"
    value     = "1"
    default_value = "0"
  }
}

# CloudWatch Log Metric Filters for Application Performance
resource "aws_cloudwatch_log_metric_filter" "application_errors" {
  name           = "${var.environment}-chainocracy-application-errors"
  log_group_name = aws_cloudwatch_log_group.application.name
  pattern        = "[timestamp, request_id, level=\"ERROR\", ...]"

  metric_transformation {
    name      = "ApplicationErrors"
    namespace = "Chainocracy/${var.environment}/Application"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "slow_queries" {
  name           = "${var.environment}-chainocracy-slow-queries"
  log_group_name = aws_cloudwatch_log_group.rds.name
  pattern        = "[timestamp, duration > 1000, query, ...]"

  metric_transformation {
    name      = "SlowQueries"
    namespace = "Chainocracy/${var.environment}/Database"
    value     = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "api_response_time" {
  name           = "${var.environment}-chainocracy-api-response-time"
  log_group_name = aws_cloudwatch_log_group.api_gateway.name
  pattern        = "[timestamp, request_id, method, path, status_code, response_time]"

  metric_transformation {
    name      = "APIResponseTime"
    namespace = "Chainocracy/${var.environment}/API"
    value     = "$response_time"
    default_value = "0"
  }
}

# CloudWatch Log Insights Queries for Security Analysis
resource "aws_cloudwatch_query_definition" "security_events" {
  name = "${var.environment}-chainocracy-security-events"

  log_group_names = [
    aws_cloudwatch_log_group.security.name,
    aws_cloudwatch_log_group.audit.name
  ]

  query_string = <<EOF
fields @timestamp, user, action, resource, result, ip_address
| filter level = "WARN" or level = "ERROR"
| sort @timestamp desc
| limit 100
EOF
}

resource "aws_cloudwatch_query_definition" "failed_authentication" {
  name = "${var.environment}-chainocracy-failed-authentication"

  log_group_names = [
    aws_cloudwatch_log_group.application.name
  ]

  query_string = <<EOF
fields @timestamp, user, ip_address, user_agent
| filter message like /Authentication failed/
| stats count() by user, ip_address
| sort count desc
EOF
}

resource "aws_cloudwatch_query_definition" "api_errors" {
  name = "${var.environment}-chainocracy-api-errors"

  log_group_names = [
    aws_cloudwatch_log_group.api_gateway.name
  ]

  query_string = <<EOF
fields @timestamp, method, path, status_code, error_message
| filter status_code >= 400
| stats count() by status_code, path
| sort count desc
EOF
}

# CloudWatch Log Destination for Cross-Account Access
resource "aws_cloudwatch_log_destination" "central_logging" {
  name       = "${var.environment}-chainocracy-central-logging"
  role_arn   = aws_iam_role.log_destination.arn
  target_arn = var.central_logging_stream_arn

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-central-logging-destination"
    Environment = var.environment
  })
}

# IAM Role for Log Destination
resource "aws_iam_role" "log_destination" {
  name = "${var.environment}-chainocracy-log-destination-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-log-destination-role"
    Environment = var.environment
  })
}

# IAM Policy for Log Destination
resource "aws_iam_role_policy" "log_destination" {
  name = "${var.environment}-chainocracy-log-destination-policy"
  role = aws_iam_role.log_destination.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kinesis:PutRecord",
          "kinesis:PutRecords"
        ]
        Resource = var.central_logging_stream_arn
      }
    ]
  })
}

# CloudWatch Log Subscription Filters for Real-time Processing
resource "aws_cloudwatch_log_subscription_filter" "security_events" {
  name            = "${var.environment}-chainocracy-security-events-filter"
  log_group_name  = aws_cloudwatch_log_group.security.name
  filter_pattern  = "[timestamp, level=\"ERROR\" || level=\"WARN\", ...]"
  destination_arn = aws_lambda_function.log_processor.arn

  depends_on = [aws_lambda_permission.log_processor]
}

resource "aws_cloudwatch_log_subscription_filter" "audit_events" {
  name            = "${var.environment}-chainocracy-audit-events-filter"
  log_group_name  = aws_cloudwatch_log_group.audit.name
  filter_pattern  = ""  # All audit events
  destination_arn = aws_lambda_function.log_processor.arn

  depends_on = [aws_lambda_permission.log_processor]
}

# Lambda Function for Log Processing
resource "aws_lambda_function" "log_processor" {
  filename         = "log_processor.zip"
  function_name    = "${var.environment}-chainocracy-log-processor"
  role            = var.lambda_execution_role_arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.log_processor_zip.output_base64sha256
  runtime         = "python3.9"
  timeout         = 300

  environment {
    variables = {
      ENVIRONMENT = var.environment
      SNS_TOPIC_ARN = var.security_sns_topic_arn
      ELASTICSEARCH_ENDPOINT = var.elasticsearch_endpoint
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-log-processor"
    Environment = var.environment
  })
}

# Archive file for Log Processor Lambda
data "archive_file" "log_processor_zip" {
  type        = "zip"
  output_path = "log_processor.zip"
  source {
    content = templatefile("${path.module}/lambda/log_processor.py", {
      environment = var.environment
    })
    filename = "lambda_function.py"
  }
}

# Lambda Permission for CloudWatch Logs
resource "aws_lambda_permission" "log_processor" {
  statement_id  = "AllowExecutionFromCloudWatchLogs"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_processor.function_name
  principal     = "logs.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.security.arn}:*"
}

# CloudWatch Dashboard for Log Monitoring
resource "aws_cloudwatch_dashboard" "logging" {
  dashboard_name = "${var.environment}-chainocracy-logging"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["Chainocracy/${var.environment}/Security", "FailedLogins"],
            [".", "SuspiciousActivity"],
            [".", "PrivilegeEscalation"],
            [".", "DataAccessViolations"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Security Events"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["Chainocracy/${var.environment}/Application", "ApplicationErrors"],
            ["Chainocracy/${var.environment}/Database", "SlowQueries"],
            ["Chainocracy/${var.environment}/API", "APIResponseTime"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Application Performance"
          period  = 300
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 12
        width  = 24
        height = 6

        properties = {
          query   = "SOURCE '${aws_cloudwatch_log_group.security.name}' | fields @timestamp, level, message | filter level = \"ERROR\" | sort @timestamp desc | limit 20"
          region  = var.aws_region
          title   = "Recent Security Errors"
        }
      }
    ]
  })
}

# CloudWatch Alarms for Log-based Metrics
resource "aws_cloudwatch_metric_alarm" "failed_logins_alarm" {
  alarm_name          = "${var.environment}-chainocracy-failed-logins"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FailedLogins"
  namespace           = "Chainocracy/${var.environment}/Security"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.failed_logins_threshold
  alarm_description   = "This metric monitors failed login attempts"
  alarm_actions       = [var.security_sns_topic_arn]

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-failed-logins-alarm"
    Environment = var.environment
  })
}

resource "aws_cloudwatch_metric_alarm" "application_errors_alarm" {
  alarm_name          = "${var.environment}-chainocracy-application-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ApplicationErrors"
  namespace           = "Chainocracy/${var.environment}/Application"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.application_errors_threshold
  alarm_description   = "This metric monitors application errors"
  alarm_actions       = [var.application_sns_topic_arn]

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-application-errors-alarm"
    Environment = var.environment
  })
}
