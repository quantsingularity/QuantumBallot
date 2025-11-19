# Web Application Firewall (WAF) Configuration
# Provides comprehensive protection against web application attacks

# WAF Web ACL for comprehensive protection
resource "aws_wafv2_web_acl" "main" {
  name  = "${var.environment}-chainocracy-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # Rule 1: AWS Managed Core Rule Set
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        # Exclude specific rules if needed for legitimate traffic
        excluded_rule {
          name = "SizeRestrictions_BODY"
        }

        excluded_rule {
          name = "GenericRFI_BODY"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # Rule 2: AWS Managed Known Bad Inputs Rule Set
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputsRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # Rule 3: AWS Managed SQL Injection Rule Set
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLiRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # Rule 4: AWS Managed Linux Operating System Rule Set
  rule {
    name     = "AWSManagedRulesLinuxRuleSet"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "LinuxRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # Rule 5: Rate Limiting Rule
  rule {
    name     = "RateLimitRule"
    priority = 5

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.rate_limit_per_5min
        aggregate_key_type = "IP"

        scope_down_statement {
          geo_match_statement {
            country_codes = var.allowed_countries
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRuleMetric"
      sampled_requests_enabled   = true
    }
  }

  # Rule 6: Geographic Restriction Rule
  rule {
    name     = "GeoRestrictionRule"
    priority = 6

    action {
      block {}
    }

    statement {
      not_statement {
        statement {
          geo_match_statement {
            country_codes = var.allowed_countries
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "GeoRestrictionRuleMetric"
      sampled_requests_enabled   = true
    }
  }

  # Rule 7: IP Reputation Rule
  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 7

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IpReputationListMetric"
      sampled_requests_enabled   = true
    }
  }

  # Rule 8: Custom Bot Control Rule
  rule {
    name     = "CustomBotControlRule"
    priority = 8

    action {
      block {}
    }

    statement {
      byte_match_statement {
        search_string = "bot"
        field_to_match {
          single_header {
            name = "user-agent"
          }
        }
        text_transformation {
          priority = 0
          type     = "LOWERCASE"
        }
        positional_constraint = "CONTAINS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CustomBotControlRuleMetric"
      sampled_requests_enabled   = true
    }
  }

  # Rule 9: Custom XSS Protection Rule
  rule {
    name     = "CustomXSSProtectionRule"
    priority = 9

    action {
      block {}
    }

    statement {
      or_statement {
        statement {
          byte_match_statement {
            search_string = "<script"
            field_to_match {
              all_query_arguments {}
            }
            text_transformation {
              priority = 0
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 1
              type     = "HTML_ENTITY_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "LOWERCASE"
            }
            positional_constraint = "CONTAINS"
          }
        }
        statement {
          byte_match_statement {
            search_string = "javascript:"
            field_to_match {
              all_query_arguments {}
            }
            text_transformation {
              priority = 0
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }
            positional_constraint = "CONTAINS"
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CustomXSSProtectionRuleMetric"
      sampled_requests_enabled   = true
    }
  }

  # Rule 10: File Upload Size Restriction
  rule {
    name     = "FileUploadSizeRestriction"
    priority = 10

    action {
      block {}
    }

    statement {
      size_constraint_statement {
        field_to_match {
          body {}
        }
        comparison_operator = "GT"
        size                = var.max_upload_size_bytes
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "FileUploadSizeRestrictionMetric"
      sampled_requests_enabled   = true
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-waf"
    Environment = var.environment
  })

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "ChainocracyWAF"
    sampled_requests_enabled   = true
  }
}

# WAF Association with Application Load Balancer
resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

# CloudWatch Log Group for WAF Logs
resource "aws_cloudwatch_log_group" "waf_log_group" {
  name              = "/aws/wafv2/${var.environment}-chainocracy"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-waf-logs"
    Environment = var.environment
  })
}

# WAF Logging Configuration
resource "aws_wafv2_web_acl_logging_configuration" "main" {
  resource_arn            = aws_wafv2_web_acl.main.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf_log_group.arn]

  redacted_fields {
    single_header {
      name = "authorization"
    }
  }

  redacted_fields {
    single_header {
      name = "cookie"
    }
  }

  redacted_fields {
    single_header {
      name = "x-api-key"
    }
  }

  logging_filter {
    default_behavior = "KEEP"

    filter {
      behavior = "KEEP"
      condition {
        action_condition {
          action = "BLOCK"
        }
      }
      requirement = "MEETS_ANY"
    }

    filter {
      behavior = "DROP"
      condition {
        action_condition {
          action = "ALLOW"
        }
      }
      requirement = "MEETS_ALL"
    }
  }
}

# Custom Rule Group for Application-Specific Rules
resource "aws_wafv2_rule_group" "custom_rules" {
  name     = "${var.environment}-chainocracy-custom-rules"
  scope    = "REGIONAL"
  capacity = 100

  # Custom rule for API endpoint protection
  rule {
    name     = "ProtectAPIEndpoints"
    priority = 1

    action {
      block {}
    }

    statement {
      and_statement {
        statement {
          byte_match_statement {
            search_string = "/api/"
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 0
              type     = "LOWERCASE"
            }
            positional_constraint = "STARTS_WITH"
          }
        }
        statement {
          not_statement {
            statement {
              byte_match_statement {
                search_string = "application/json"
                field_to_match {
                  single_header {
                    name = "content-type"
                  }
                }
                text_transformation {
                  priority = 0
                  type     = "LOWERCASE"
                }
                positional_constraint = "CONTAINS"
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ProtectAPIEndpointsMetric"
      sampled_requests_enabled   = true
    }
  }

  # Custom rule for admin panel protection
  rule {
    name     = "ProtectAdminPanel"
    priority = 2

    action {
      block {}
    }

    statement {
      and_statement {
        statement {
          byte_match_statement {
            search_string = "/admin"
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 0
              type     = "LOWERCASE"
            }
            positional_constraint = "STARTS_WITH"
          }
        }
        statement {
          not_statement {
            statement {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.admin_whitelist.arn
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ProtectAdminPanelMetric"
      sampled_requests_enabled   = true
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-custom-rules"
    Environment = var.environment
  })

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "CustomRulesMetric"
    sampled_requests_enabled   = true
  }
}

# IP Set for Admin Whitelist
resource "aws_wafv2_ip_set" "admin_whitelist" {
  name               = "${var.environment}-chainocracy-admin-whitelist"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.admin_whitelist_ips

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-admin-whitelist"
    Environment = var.environment
  })
}

# IP Set for Known Bad IPs
resource "aws_wafv2_ip_set" "bad_ips" {
  name               = "${var.environment}-chainocracy-bad-ips"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.blocked_ips

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-bad-ips"
    Environment = var.environment
  })
}

# CloudWatch Alarms for WAF Metrics
resource "aws_cloudwatch_metric_alarm" "waf_blocked_requests" {
  alarm_name          = "${var.environment}-chainocracy-waf-blocked-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.blocked_requests_threshold
  alarm_description   = "This metric monitors blocked requests by WAF"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    WebACL = aws_wafv2_web_acl.main.name
    Region = var.aws_region
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-waf-blocked-requests-alarm"
    Environment = var.environment
  })
}

resource "aws_cloudwatch_metric_alarm" "waf_rate_limit_triggered" {
  alarm_name          = "${var.environment}-chainocracy-waf-rate-limit"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.rate_limit_threshold
  alarm_description   = "This metric monitors rate limiting triggers"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    WebACL = aws_wafv2_web_acl.main.name
    Region = var.aws_region
    Rule   = "RateLimitRule"
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-waf-rate-limit-alarm"
    Environment = var.environment
  })
}
