# """
# AWS Lambda function for log processing and security analysis
# Processes CloudWatch logs and sends alerts for security events
# """

import base64
import gzip
import json
import logging
import os
import re
from datetime import datetime

import boto3
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
sns_client = boto3.client("sns")
es_client = boto3.client("es")

# Security patterns to detect
SECURITY_PATTERNS = {
    "sql_injection": [
        r"(?i)(union\s+select|select\s+.*\s+from|insert\s+into|delete\s+from|drop\s+table)",
        r"(?i)(\'\s*or\s+\'\d+\'\s*=\s*\'\d+|\'\s*or\s+\d+\s*=\s*\d+)",
        r"(?i)(exec\s*\(|execute\s*\(|sp_executesql)",
    ],
    "xss_attempt": [
        r"(?i)(<script[^>]*>|</script>|javascript:|vbscript:|onload=|onerror=)",
        r"(?i)(alert\s*\(|confirm\s*\(|prompt\s*\()",
        r"(?i)(<iframe|<object|<embed|<applet)",
    ],
    "command_injection": [
        r"(?i)(;\s*cat\s+|;\s*ls\s+|;\s*pwd|;\s*whoami)",
        r"(?i)(\|\s*nc\s+|\|\s*netcat\s+|\|\s*wget\s+|\|\s*curl\s+)",
        r"(?i)(&&\s*rm\s+|&&\s*chmod\s+|&&\s*chown\s+)",
    ],
    "path_traversal": [
        r"(?i)(\.\.\/|\.\.\\|%2e%2e%2f|%2e%2e%5c)",
        r"(?i)(\/etc\/passwd|\/etc\/shadow|\/windows\/system32)",
        r"(?i)(\.\.%2f|\.\.%5c|%252e%252e%252f)",
    ],
    "brute_force": [
        r"(?i)(failed\s+login|authentication\s+failed|invalid\s+credentials)",
        r"(?i)(too\s+many\s+attempts|account\s+locked|rate\s+limit\s+exceeded)",
    ],
    "privilege_escalation": [
        r"(?i)(sudo\s+su|su\s+-|privilege\s+escalation)",
        r"(?i)(unauthorized\s+access|permission\s+denied|access\s+violation)",
    ],
}


def lambda_handler(event, context):
    #    """
    #    Main Lambda handler for log processing
    #    """
    try:
        # Process CloudWatch Logs data
        cw_data = event["awslogs"]["data"]
        compressed_payload = base64.b64decode(cw_data)
        uncompressed_payload = gzip.decompress(compressed_payload)
        log_data = json.loads(uncompressed_payload)

        logger.info(f"Processing {len(log_data['logEvents'])} log events")

        # Process each log event
        security_events = []
        for log_event in log_data["logEvents"]:
            processed_event = process_log_event(log_event, log_data["logGroup"])
            if processed_event:
                security_events.append(processed_event)

        # Send security events to Elasticsearch
        if security_events:
            send_to_elasticsearch(security_events)

            # Send high-severity alerts
            high_severity_events = [
                e for e in security_events if e.get("severity") == "HIGH"
            ]
            if high_severity_events:
                send_security_alert(high_severity_events)

        return {
            "statusCode": 200,
            "body": json.dumps(
                {
                    "processed_events": len(log_data["logEvents"]),
                    "security_events": len(security_events),
                    "high_severity_events": len(
                        [e for e in security_events if e.get("severity") == "HIGH"]
                    ),
                }
            ),
        }

    except Exception as e:
        logger.error(f"Error processing logs: {str(e)}")
        raise e


def process_log_event(log_event, log_group):
    #    """
    #    Process individual log event for security analysis
    #    """
    try:
        message = log_event["message"]
        timestamp = log_event["timestamp"]

        # Parse JSON log messages
        try:
            log_json = json.loads(message)
            message_text = log_json.get("message", message)
            level = log_json.get("level", "INFO")
            user = log_json.get("user", "unknown")
            ip_address = log_json.get("ip_address", "unknown")
            user_agent = log_json.get("user_agent", "unknown")
        except json.JSONDecodeError:
            message_text = message
            level = extract_log_level(message)
            user = extract_user(message)
            ip_address = extract_ip_address(message)
            user_agent = extract_user_agent(message)

        # Analyze message for security patterns
        security_findings = analyze_security_patterns(message_text)

        if security_findings:
            return {
                "timestamp": datetime.fromtimestamp(timestamp / 1000).isoformat(),
                "log_group": log_group,
                "level": level,
                "user": user,
                "ip_address": ip_address,
                "user_agent": user_agent,
                "message": message_text,
                "security_findings": security_findings,
                "severity": determine_severity(security_findings),
                "environment": os.environ.get("ENVIRONMENT", "unknown"),
            }

        return None

    except Exception as e:
        logger.error(f"Error processing log event: {str(e)}")
        return None


def analyze_security_patterns(message):
    #    """
    #    Analyze message for security patterns
    #    """
    findings = []

    for pattern_type, patterns in SECURITY_PATTERNS.items():
        for pattern in patterns:
            if re.search(pattern, message):
                findings.append(
                    {
                        "type": pattern_type,
                        "pattern": pattern,
                        "matched_text": re.search(pattern, message).group(0),
                    }
                )

    return findings


def determine_severity(security_findings):
    #    """
    #    Determine severity based on security findings
    #    """
    high_severity_types = ["sql_injection", "command_injection", "privilege_escalation"]
    medium_severity_types = ["xss_attempt", "path_traversal"]

    for finding in security_findings:
        if finding["type"] in high_severity_types:
            return "HIGH"
        elif finding["type"] in medium_severity_types:
            return "MEDIUM"

    return "LOW"


def extract_log_level(message):
    #    """
    #    Extract log level from message
    #    """
    level_pattern = r"\b(DEBUG|INFO|WARN|ERROR|FATAL)\b"
    match = re.search(level_pattern, message, re.IGNORECASE)
    return match.group(1).upper() if match else "INFO"


def extract_user(message):
    #    """
    #    Extract user from message
    #    """
    user_patterns = [
        r"user[:\s]+([a-zA-Z0-9_\-\.@]+)",
        r"username[:\s]+([a-zA-Z0-9_\-\.@]+)",
        r"email[:\s]+([a-zA-Z0-9_\-\.@]+)",
    ]

    for pattern in user_patterns:
        match = re.search(pattern, message, re.IGNORECASE)
        if match:
            return match.group(1)

    return "unknown"


def extract_ip_address(message):
    #    """
    #    Extract IP address from message
    #    """
    ip_pattern = r"\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b"
    match = re.search(ip_pattern, message)
    return match.group(0) if match else "unknown"


def extract_user_agent(message):
    #    """
    #    Extract user agent from message
    #    """
    ua_pattern = r"user[_\-\s]?agent[:\s]+([^\n\r]+)"
    match = re.search(ua_pattern, message, re.IGNORECASE)
    return match.group(1).strip() if match else "unknown"


def send_to_elasticsearch(security_events):
    #    """
    #    Send security events to Elasticsearch
    #    """
    try:
        es_endpoint = os.environ.get("ELASTICSEARCH_ENDPOINT")
        if not es_endpoint:
            logger.warning("Elasticsearch endpoint not configured")
            return

        # Prepare bulk index request
        bulk_data = []
        for event in security_events:
            index_action = {
                "index": {
                    "_index": f"QuantumBallot-security-{datetime.now().strftime('%Y-%m')}",
                    "_type": "_doc",
                }
            }
            bulk_data.append(json.dumps(index_action))
            bulk_data.append(json.dumps(event))

        # Send to Elasticsearch (implementation would depend on your ES setup)
        logger.info(f"Would send {len(security_events)} events to Elasticsearch")

    except Exception as e:
        logger.error(f"Error sending to Elasticsearch: {str(e)}")


def send_security_alert(high_severity_events):
    #    """
    #    Send security alert for high-severity events
    #    """
    try:
        sns_topic_arn = os.environ.get("SNS_TOPIC_ARN")
        if not sns_topic_arn:
            logger.warning("SNS topic ARN not configured")
            return

        # Prepare alert message
        alert_message = f"""
SECURITY ALERT - {os.environ.get('ENVIRONMENT', 'Unknown')} Environment

{len(high_severity_events)} high-severity security events detected:

#"""
        #
        #        for event in high_severity_events[:5]:  # Limit to first 5 events
        #            alert_message += f"""
        # Timestamp: {event['timestamp']}
        # User: {event['user']}
        # IP Address: {event['ip_address']}
        # Findings: {', '.join([f['type'] for f in event['security_findings']])}
        # Message: {event['message'][:200]}...
        #
        # """

        if len(high_severity_events) > 5:
            alert_message += f"\n... and {len(high_severity_events) - 5} more events"

        # Send SNS notification
        sns_client.publish(
            TopicArn=sns_topic_arn,
            Subject=f"Security Alert - {os.environ.get('ENVIRONMENT', 'Unknown')} Environment",
            Message=alert_message,
        )

        logger.info(f"Sent security alert for {len(high_severity_events)} events")

    except Exception as e:
        logger.error(f"Error sending security alert: {str(e)}")


def enrich_with_threat_intelligence(event):
    #    """
    #    Enrich event with threat intelligence data
    #    """
    try:
        ip_address = event.get("ip_address", "")

        # Check against known malicious IPs (placeholder implementation)
        malicious_ips = get_malicious_ip_list()

        if ip_address in malicious_ips:
            event["threat_intelligence"] = {
                "malicious_ip": True,
                "threat_type": malicious_ips[ip_address],
                "confidence": "HIGH",
            }

        return event

    except Exception as e:
        logger.error(f"Error enriching with threat intelligence: {str(e)}")
        return event


def get_malicious_ip_list():
    #    """
    #    Get list of known malicious IPs (placeholder implementation)
    #    """
    # In a real implementation, this would fetch from threat intelligence feeds
    return {
        "192.168.1.100": "botnet",
        "10.0.0.50": "scanner",
        "172.16.0.25": "malware_c2",
    }


def calculate_risk_score(event):
    #    """
    #    Calculate risk score for the event
    #    """
    try:
        score = 0

        # Base score for security findings
        for finding in event.get("security_findings", []):
            if finding["type"] in ["sql_injection", "command_injection"]:
                score += 50
            elif finding["type"] in ["xss_attempt", "path_traversal"]:
                score += 30
            else:
                score += 10

        # Additional score for threat intelligence
        if event.get("threat_intelligence", {}).get("malicious_ip"):
            score += 40

        # Additional score for repeated attempts
        if "brute_force" in [f["type"] for f in event.get("security_findings", [])]:
            score += 25

        event["risk_score"] = min(score, 100)  # Cap at 100
        return event

    except Exception as e:
        logger.error(f"Error calculating risk score: {str(e)}")
        event["risk_score"] = 0
        return event
