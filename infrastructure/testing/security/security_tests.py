#!/usr/bin/env python3
#"""
#Comprehensive Security Testing Suite for QuantumBallot Infrastructure
#Implements financial-grade security testing and vulnerability assessment
#"""

import json
import os
import socket
import ssl
import subprocess
import sys
import time
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple

import boto3
import docker
import nmap
import pytest
import requests
import sqlparse
import yaml
from botocore.exceptions import ClientError
from cryptography import x509
from cryptography.hazmat.backends import default_backend
from kubernetes import client, config


class SecurityTestSuite:
#    """Main security testing suite for QuantumBallot infrastructure"""
#
#    def __init__(self, environment: str = "test"):
#        self.environment = environment
#        self.aws_session = boto3.Session()
#        self.docker_client = docker.from_env()
#        self.results = []
#
#        # Load Kubernetes config
#        try:
#            config.load_incluster_config()
#        except:
#            config.load_kube_config()
#
#        self.k8s_v1 = client.CoreV1Api()
#        self.k8s_apps_v1 = client.AppsV1Api()
#
#    def run_all_tests(self) -> Dict:
#        """Run all security tests and return comprehensive results"""
        print(
            f"Starting comprehensive security testing for {self.environment} environment"
        )

        test_results = {
            "environment": self.environment,
            "timestamp": datetime.utcnow().isoformat(),
            "tests": {},
        }

        # Infrastructure Security Tests
        test_results["tests"]["infrastructure"] = self.test_infrastructure_security()

        # Container Security Tests
        test_results["tests"]["containers"] = self.test_container_security()

        # Network Security Tests
        test_results["tests"]["network"] = self.test_network_security()

        # Application Security Tests
        test_results["tests"]["application"] = self.test_application_security()

        # Compliance Tests
        test_results["tests"]["compliance"] = self.test_compliance()

        # Vulnerability Scanning
        test_results["tests"]["vulnerabilities"] = self.test_vulnerabilities()

        # Generate security report
        self.generate_security_report(test_results)

        return test_results

    def test_infrastructure_security(self) -> Dict:
#        """Test AWS infrastructure security configurations"""
#        print("Testing infrastructure security...")
#
#        results = {
#            "vpc_security": self.test_vpc_security(),
#            "iam_security": self.test_iam_security(),
#            "encryption": self.test_encryption_at_rest(),
#            "logging": self.test_audit_logging(),
#            "backup": self.test_backup_security(),
#        }
#
#        return results
#
#    def test_vpc_security(self) -> Dict:
#        """Test VPC security configurations"""
        ec2 = self.aws_session.client("ec2")
        results = {"passed": [], "failed": [], "warnings": []}

        try:
            # Test VPC Flow Logs
            vpcs = ec2.describe_vpcs()["Vpcs"]
            for vpc in vpcs:
                vpc_id = vpc["VpcId"]

                # Check if flow logs are enabled
                flow_logs = ec2.describe_flow_logs(
                    Filters=[{"Name": "resource-id", "Values": [vpc_id]}]
                )["FlowLogs"]

                if flow_logs:
                    results["passed"].append(f"VPC {vpc_id} has flow logs enabled")
                else:
                    results["failed"].append(f"VPC {vpc_id} missing flow logs")

            # Test Security Groups
            security_groups = ec2.describe_security_groups()["SecurityGroups"]
            for sg in security_groups:
                sg_id = sg["GroupId"]

                # Check for overly permissive rules
                for rule in sg.get("IpPermissions", []):
                    for ip_range in rule.get("IpRanges", []):
                        if ip_range.get("CidrIp") == "0.0.0.0/0":
                            if rule.get("FromPort") == 22:  # SSH
                                results["failed"].append(
                                    f"SG {sg_id} allows SSH from anywhere"
                                )
                            elif rule.get("FromPort") == 3389:  # RDP
                                results["failed"].append(
                                    f"SG {sg_id} allows RDP from anywhere"
                                )
                            elif rule.get("FromPort") not in [80, 443]:
                                results["warnings"].append(
                                    f"SG {sg_id} allows {rule.get('FromPort')} from anywhere"
                                )

            # Test NACLs
            nacls = ec2.describe_network_acls()["NetworkAcls"]
            for nacl in nacls:
                if not nacl["IsDefault"]:
                    results["passed"].append(
                        f"Custom NACL {nacl['NetworkAclId']} configured"
                    )

        except ClientError as e:
            results["failed"].append(f"Error testing VPC security: {str(e)}")

        return results

    def test_iam_security(self) -> Dict:
#        """Test IAM security configurations"""
#        iam = self.aws_session.client("iam")
#        results = {"passed": [], "failed": [], "warnings": []}
#
#        try:
#            # Test for overly permissive policies
#            policies = iam.list_policies(Scope="Local")["Policies"]
#            for policy in policies:
#                policy_arn = policy["Arn"]
#
#                # Get policy document
#                policy_version = iam.get_policy_version(
#                    PolicyArn=policy_arn, VersionId=policy["DefaultVersionId"]
#                )
#
#                policy_doc = policy_version["PolicyVersion"]["Document"]
#
#                # Check for admin access
#                for statement in policy_doc.get("Statement", []):
#                    if statement.get("Effect") == "Allow":
#                        actions = statement.get("Action", [])
#                        if isinstance(actions, str):
#                            actions = [actions]
#
#                        if "*" in actions:
#                            results["failed"].append(
#                                f"Policy {policy['PolicyName']} grants admin access"
#                            )
#
#                        # Check for dangerous actions
#                        dangerous_actions = ["iam:*", "sts:AssumeRole", "ec2:*"]
#                        for action in actions:
#                            if any(
#                                dangerous in action for dangerous in dangerous_actions
#                            ):
#                                results["warnings"].append(
#                                    f"Policy {policy['PolicyName']} has privileged action: {action}"
#                                )
#
#            # Test MFA requirements
#            users = iam.list_users()["Users"]
#            for user in users:
#                username = user["UserName"]
#
#                # Check if user has MFA enabled
#                mfa_devices = iam.list_mfa_devices(UserName=username)["MFADevices"]
#                if not mfa_devices:
#                    results["warnings"].append(
#                        f"User {username} does not have MFA enabled"
#                    )
#                else:
#                    results["passed"].append(f"User {username} has MFA enabled")
#
#            # Test password policy
#            try:
#                password_policy = iam.get_account_password_policy()["PasswordPolicy"]
#
#                if password_policy.get("MinimumPasswordLength", 0) < 12:
#                    results["failed"].append(
#                        "Password policy requires less than 12 characters"
#                    )
#                else:
#                    results["passed"].append(
#                        "Password policy meets length requirements"
#                    )
#
#                if not password_policy.get("RequireSymbols", False):
#                    results["warnings"].append(
#                        "Password policy does not require symbols"
#                    )
#
#            except ClientError:
#                results["failed"].append("No password policy configured")
#
#        except ClientError as e:
#            results["failed"].append(f"Error testing IAM security: {str(e)}")
#
#        return results
#
#    def test_encryption_at_rest(self) -> Dict:
#        """Test encryption at rest configurations"""
        results = {"passed": [], "failed": [], "warnings": []}

        try:
            # Test RDS encryption
            rds = self.aws_session.client("rds")
            db_instances = rds.describe_db_instances()["DBInstances"]

            for db in db_instances:
                db_id = db["DBInstanceIdentifier"]
                if db.get("StorageEncrypted", False):
                    results["passed"].append(f"RDS instance {db_id} is encrypted")
                else:
                    results["failed"].append(f"RDS instance {db_id} is not encrypted")

            # Test S3 encryption
            s3 = self.aws_session.client("s3")
            buckets = s3.list_buckets()["Buckets"]

            for bucket in buckets:
                bucket_name = bucket["Name"]
                try:
                    encryption = s3.get_bucket_encryption(Bucket=bucket_name)
                    results["passed"].append(
                        f"S3 bucket {bucket_name} has encryption enabled"
                    )
                except ClientError:
                    results["failed"].append(
                        f"S3 bucket {bucket_name} does not have encryption enabled"
                    )

            # Test EBS encryption
            ec2 = self.aws_session.client("ec2")
            volumes = ec2.describe_volumes()["Volumes"]

            for volume in volumes:
                volume_id = volume["VolumeId"]
                if volume.get("Encrypted", False):
                    results["passed"].append(f"EBS volume {volume_id} is encrypted")
                else:
                    results["failed"].append(f"EBS volume {volume_id} is not encrypted")

        except ClientError as e:
            results["failed"].append(f"Error testing encryption: {str(e)}")

        return results

    def test_audit_logging(self) -> Dict:
#        """Test audit logging configurations"""
#        results = {"passed": [], "failed": [], "warnings": []}
#
#        try:
#            # Test CloudTrail
#            cloudtrail = self.aws_session.client("cloudtrail")
#            trails = cloudtrail.describe_trails()["trailList"]
#
#            if not trails:
#                results["failed"].append("No CloudTrail trails configured")
#            else:
#                for trail in trails:
#                    trail_name = trail["Name"]
#
#                    # Check if trail is logging
#                    status = cloudtrail.get_trail_status(Name=trail_name)
#                    if status["IsLogging"]:
#                        results["passed"].append(
#                            f"CloudTrail {trail_name} is actively logging"
#                        )
#                    else:
#                        results["failed"].append(
#                            f"CloudTrail {trail_name} is not logging"
#                        )
#
#                    # Check if trail includes global events
#                    if trail.get("IncludeGlobalServiceEvents", False):
#                        results["passed"].append(
#                            f"CloudTrail {trail_name} includes global events"
#                        )
#                    else:
#                        results["warnings"].append(
#                            f"CloudTrail {trail_name} does not include global events"
#                        )
#
#            # Test VPC Flow Logs (already covered in VPC security)
#
#            # Test CloudWatch Logs retention
#            logs = self.aws_session.client("logs")
#            log_groups = logs.describe_log_groups()["logGroups"]
#
#            for log_group in log_groups:
#                group_name = log_group["logGroupName"]
#                retention = log_group.get("retentionInDays")
#
#                if retention and retention >= 365:
#                    results["passed"].append(
#                        f"Log group {group_name} has adequate retention"
#                    )
#                else:
#                    results["warnings"].append(
#                        f"Log group {group_name} has insufficient retention"
#                    )
#
#        except ClientError as e:
#            results["failed"].append(f"Error testing audit logging: {str(e)}")
#
#        return results
#
#    def test_backup_security(self) -> Dict:
#        """Test backup security configurations"""
        results = {"passed": [], "failed": [], "warnings": []}

        try:
            # Test AWS Backup
            backup = self.aws_session.client("backup")

            # Check backup plans
            backup_plans = backup.list_backup_plans()["BackupPlansList"]
            if not backup_plans:
                results["warnings"].append("No backup plans configured")
            else:
                for plan in backup_plans:
                    plan_name = plan["BackupPlanName"]
                    results["passed"].append(f"Backup plan {plan_name} configured")

            # Check backup vaults
            backup_vaults = backup.list_backup_vaults()["BackupVaultList"]
            for vault in backup_vaults:
                vault_name = vault["BackupVaultName"]
                if vault.get("EncryptionKeyArn"):
                    results["passed"].append(f"Backup vault {vault_name} is encrypted")
                else:
                    results["failed"].append(
                        f"Backup vault {vault_name} is not encrypted"
                    )

        except ClientError as e:
            results["failed"].append(f"Error testing backup security: {str(e)}")

        return results

    def test_container_security(self) -> Dict:
#        """Test container security configurations"""
#        print("Testing container security...")
#
#        results = {
#            "image_security": self.test_image_security(),
#            "runtime_security": self.test_runtime_security(),
#            "kubernetes_security": self.test_kubernetes_security(),
#        }
#
#        return results
#
#    def test_image_security(self) -> Dict:
#        """Test Docker image security"""
        results = {"passed": [], "failed": [], "warnings": []}

        try:
            # Get all images
            images = self.docker_client.images.list()

            for image in images:
                image_name = image.tags[0] if image.tags else image.id[:12]

                # Check if image runs as root
                config = image.attrs.get("Config", {})
                user = config.get("User", "root")

                if user == "root" or user == "0":
                    results["failed"].append(f"Image {image_name} runs as root user")
                else:
                    results["passed"].append(
                        f"Image {image_name} runs as non-root user: {user}"
                    )

                # Check for exposed privileged ports
                exposed_ports = config.get("ExposedPorts", {})
                for port in exposed_ports:
                    port_num = int(port.split("/")[0])
                    if port_num < 1024:
                        results["warnings"].append(
                            f"Image {image_name} exposes privileged port {port}"
                        )

                # Check for secrets in environment variables
                env_vars = config.get("Env", [])
                for env_var in env_vars:
                    env_lower = env_var.lower()
                    if any(
                        secret in env_lower
                        for secret in ["password", "secret", "key", "token"]
                    ):
                        results["failed"].append(
                            f"Image {image_name} may contain secrets in env vars"
                        )

            # Run vulnerability scanning with Trivy (if available)
            try:
                for image in images:
                    if image.tags:
                        image_name = image.tags[0]
                        trivy_result = subprocess.run(
                            ["trivy", "image", "--format", "json", image_name],
                            capture_output=True,
                            text=True,
                            timeout=300,
                        )

                        if trivy_result.returncode == 0:
                            scan_data = json.loads(trivy_result.stdout)
                            vulnerabilities = scan_data.get("Results", [])

                            high_vulns = 0
                            critical_vulns = 0

                            for result in vulnerabilities:
                                for vuln in result.get("Vulnerabilities", []):
                                    severity = vuln.get("Severity", "").upper()
                                    if severity == "HIGH":
                                        high_vulns += 1
                                    elif severity == "CRITICAL":
                                        critical_vulns += 1

                            if critical_vulns > 0:
                                results["failed"].append(
                                    f"Image {image_name} has {critical_vulns} critical vulnerabilities"
                                )
                            elif high_vulns > 0:
                                results["warnings"].append(
                                    f"Image {image_name} has {high_vulns} high vulnerabilities"
                                )
                            else:
                                results["passed"].append(
                                    f"Image {image_name} has no high/critical vulnerabilities"
                                )

            except (subprocess.TimeoutExpired, FileNotFoundError):
                results["warnings"].append("Trivy vulnerability scanner not available")

        except Exception as e:
            results["failed"].append(f"Error testing image security: {str(e)}")

        return results

    def test_runtime_security(self) -> Dict:
#        """Test container runtime security"""
#        results = {"passed": [], "failed": [], "warnings": []}
#
#        try:
#            # Get running containers
#            containers = self.docker_client.containers.list()
#
#            for container in containers:
#                container_name = container.name
#
#                # Check security options
#                security_opt = container.attrs.get("HostConfig", {}).get(
#                    "SecurityOpt", []
#                )
#
#                if "no-new-privileges:true" in security_opt:
#                    results["passed"].append(
#                        f"Container {container_name} has no-new-privileges"
#                    )
#                else:
#                    results["warnings"].append(
#                        f"Container {container_name} missing no-new-privileges"
#                    )
#
#                # Check if running as root
#                config = container.attrs.get("Config", {})
#                user = config.get("User", "root")
#
#                if user == "root" or user == "0":
#                    results["failed"].append(
#                        f"Container {container_name} running as root"
#                    )
#                else:
#                    results["passed"].append(
#                        f"Container {container_name} running as user: {user}"
#                    )
#
#                # Check capabilities
#                cap_add = container.attrs.get("HostConfig", {}).get("CapAdd", [])
#                cap_drop = container.attrs.get("HostConfig", {}).get("CapDrop", [])
#
#                if "ALL" in cap_drop:
#                    results["passed"].append(
#                        f"Container {container_name} drops all capabilities"
#                    )
#                elif cap_drop:
#                    results["passed"].append(
#                        f"Container {container_name} drops capabilities: {cap_drop}"
#                    )
#                else:
#                    results["warnings"].append(
#                        f"Container {container_name} does not drop capabilities"
#                    )
#
#                if cap_add:
#                    results["warnings"].append(
#                        f"Container {container_name} adds capabilities: {cap_add}"
#                    )
#
#                # Check read-only filesystem
#                read_only = container.attrs.get("HostConfig", {}).get(
#                    "ReadonlyRootfs", False
#                )
#                if read_only:
#                    results["passed"].append(
#                        f"Container {container_name} has read-only filesystem"
#                    )
#                else:
#                    results["warnings"].append(
#                        f"Container {container_name} has writable filesystem"
#                    )
#
#        except Exception as e:
#            results["failed"].append(f"Error testing runtime security: {str(e)}")
#
#        return results
#
#    def test_kubernetes_security(self) -> Dict:
#        """Test Kubernetes security configurations"""
        results = {"passed": [], "failed": [], "warnings": []}

        try:
            # Test Pod Security Standards
            namespaces = self.k8s_v1.list_namespace()

            for namespace in namespaces.items:
                ns_name = namespace.metadata.name

                # Check for security context constraints
                pods = self.k8s_v1.list_namespaced_pod(namespace=ns_name)

                for pod in pods.items:
                    pod_name = pod.metadata.name

                    # Check security context
                    security_context = pod.spec.security_context
                    if security_context:
                        if security_context.run_as_non_root:
                            results["passed"].append(f"Pod {pod_name} runs as non-root")
                        else:
                            results["failed"].append(f"Pod {pod_name} may run as root")

                        if security_context.fs_group:
                            results["passed"].append(f"Pod {pod_name} has fsGroup set")
                    else:
                        results["warnings"].append(
                            f"Pod {pod_name} has no security context"
                        )

                    # Check container security contexts
                    for container in pod.spec.containers:
                        container_name = container.name

                        if container.security_context:
                            sc = container.security_context

                            if sc.run_as_non_root:
                                results["passed"].append(
                                    f"Container {container_name} runs as non-root"
                                )

                            if sc.read_only_root_filesystem:
                                results["passed"].append(
                                    f"Container {container_name} has read-only filesystem"
                                )

                            if sc.allow_privilege_escalation is False:
                                results["passed"].append(
                                    f"Container {container_name} prevents privilege escalation"
                                )
                            else:
                                results["warnings"].append(
                                    f"Container {container_name} allows privilege escalation"
                                )
                        else:
                            results["warnings"].append(
                                f"Container {container_name} has no security context"
                            )

                        # Check resource limits
                        if container.resources:
                            if container.resources.limits:
                                results["passed"].append(
                                    f"Container {container_name} has resource limits"
                                )
                            else:
                                results["warnings"].append(
                                    f"Container {container_name} has no resource limits"
                                )

            # Test Network Policies
            try:
                network_policies = (
                    client.NetworkingV1Api().list_network_policy_for_all_namespaces()
                )
                if network_policies.items:
                    results["passed"].append(
                        f"Found {len(network_policies.items)} network policies"
                    )
                else:
                    results["warnings"].append("No network policies configured")
            except Exception:
                results["warnings"].append("Could not check network policies")

        except Exception as e:
            results["failed"].append(f"Error testing Kubernetes security: {str(e)}")

        return results

    def test_network_security(self) -> Dict:
#        """Test network security configurations"""
#        print("Testing network security...")
#
#        results = {
#            "port_scanning": self.test_port_scanning(),
#            "ssl_tls": self.test_ssl_tls_configuration(),
#            "firewall": self.test_firewall_rules(),
#        }
#
#        return results
#
#    def test_port_scanning(self) -> Dict:
#        """Perform network port scanning"""
        results = {"passed": [], "failed": [], "warnings": []}

        try:
            # Scan common targets
            targets = ["localhost", "127.0.0.1"]

            nm = nmap.PortScanner()

            for target in targets:
                try:
                    # Scan common ports
                    scan_result = nm.scan(target, "22,80,443,3000,5432,6379,9090,3001")

                    for host in scan_result["scan"]:
                        for port in scan_result["scan"][host]["tcp"]:
                            state = scan_result["scan"][host]["tcp"][port]["state"]
                            service = scan_result["scan"][host]["tcp"][port]["name"]

                            if state == "open":
                                if port in [22, 3389]:  # SSH, RDP
                                    results["warnings"].append(
                                        f"Administrative port {port} ({service}) open on {host}"
                                    )
                                elif port in [
                                    80,
                                    443,
                                    3000,
                                    9090,
                                    3001,
                                ]:  # Web services
                                    results["passed"].append(
                                        f"Web service port {port} ({service}) open on {host}"
                                    )
                                else:
                                    results["warnings"].append(
                                        f"Port {port} ({service}) open on {host}"
                                    )

                except Exception as e:
                    results["warnings"].append(f"Could not scan {target}: {str(e)}")

        except Exception as e:
            results["failed"].append(f"Error in port scanning: {str(e)}")

        return results

    def test_ssl_tls_configuration(self) -> Dict:
#        """Test SSL/TLS configurations"""
#        results = {"passed": [], "failed": [], "warnings": []}
#
#        # Test endpoints
#        endpoints = [
#            ("localhost", 443),
#            ("localhost", 8080),
#        ]
#
#        for host, port in endpoints:
#            try:
#                # Test SSL/TLS connection
#                context = ssl.create_default_context()
#
#                with socket.create_connection((host, port), timeout=10) as sock:
#                    with context.wrap_socket(sock, server_hostname=host) as ssock:
#                        cert = ssock.getpeercert(binary_form=True)
#                        cert_obj = x509.load_der_x509_certificate(
#                            cert, default_backend()
#                        )
#
#                        # Check certificate validity
#                        now = datetime.utcnow()
#                        if cert_obj.not_valid_after > now:
#                            results["passed"].append(
#                                f"Certificate for {host}:{port} is valid"
#                            )
#                        else:
#                            results["failed"].append(
#                                f"Certificate for {host}:{port} is expired"
#                            )
#
#                        # Check certificate expiry warning
#                        days_until_expiry = (cert_obj.not_valid_after - now).days
#                        if days_until_expiry < 30:
#                            results["warnings"].append(
#                                f"Certificate for {host}:{port} expires in {days_until_expiry} days"
#                            )
#
#                        # Check TLS version
#                        tls_version = ssock.version()
#                        if tls_version in ["TLSv1.2", "TLSv1.3"]:
#                            results["passed"].append(
#                                f"{host}:{port} uses secure TLS version: {tls_version}"
#                            )
#                        else:
#                            results["failed"].append(
#                                f"{host}:{port} uses insecure TLS version: {tls_version}"
#                            )
#
#            except ssl.SSLError as e:
#                results["failed"].append(f"SSL error for {host}:{port}: {str(e)}")
#            except (socket.timeout, ConnectionRefusedError):
#                results["warnings"].append(f"Could not connect to {host}:{port}")
#            except Exception as e:
#                results["warnings"].append(f"Error testing {host}:{port}: {str(e)}")
#
#        return results
#
#    def test_firewall_rules(self) -> Dict:
#        """Test firewall configurations"""
        results = {"passed": [], "failed": [], "warnings": []}

        try:
            # Test iptables rules (if available)
            try:
                iptables_result = subprocess.run(
                    ["sudo", "iptables", "-L", "-n"],
                    capture_output=True,
                    text=True,
                    timeout=30,
                )

                if iptables_result.returncode == 0:
                    output = iptables_result.stdout

                    if "DROP" in output or "REJECT" in output:
                        results["passed"].append("Firewall has restrictive rules")
                    else:
                        results["warnings"].append("Firewall may be too permissive")

            except (subprocess.TimeoutExpired, FileNotFoundError, PermissionError):
                results["warnings"].append("Could not check iptables rules")

            # Test UFW status (if available)
            try:
                ufw_result = subprocess.run(
                    ["sudo", "ufw", "status"],
                    capture_output=True,
                    text=True,
                    timeout=30,
                )

                if ufw_result.returncode == 0:
                    if "Status: active" in ufw_result.stdout:
                        results["passed"].append("UFW firewall is active")
                    else:
                        results["warnings"].append("UFW firewall is not active")

            except (subprocess.TimeoutExpired, FileNotFoundError, PermissionError):
                results["warnings"].append("Could not check UFW status")

        except Exception as e:
            results["failed"].append(f"Error testing firewall: {str(e)}")

        return results

    def test_application_security(self) -> Dict:
#        """Test application-level security"""
#        print("Testing application security...")
#
#        results = {
#            "web_security": self.test_web_security(),
#            "api_security": self.test_api_security(),
#            "authentication": self.test_authentication_security(),
#        }
#
#        return results
#
#    def test_web_security(self) -> Dict:
#        """Test web application security"""
        results = {"passed": [], "failed": [], "warnings": []}

        # Test endpoints
        endpoints = [
            "http://localhost:8080",
            "http://localhost:3000",
            "http://localhost:3001",
        ]

        for endpoint in endpoints:
            try:
                response = requests.get(endpoint, timeout=10, allow_redirects=False)

                # Check security headers
                headers = response.headers

                security_headers = {
                    "X-Frame-Options": "SAMEORIGIN",
                    "X-Content-Type-Options": "nosniff",
                    "X-XSS-Protection": "1; mode=block",
                    "Strict-Transport-Security": None,
                    "Content-Security-Policy": None,
                }

                for header, expected_value in security_headers.items():
                    if header in headers:
                        if expected_value and headers[header] != expected_value:
                            results["warnings"].append(
                                f"{endpoint} has incorrect {header}: {headers[header]}"
                            )
                        else:
                            results["passed"].append(f"{endpoint} has {header} header")
                    else:
                        results["failed"].append(f"{endpoint} missing {header} header")

                # Check for server information disclosure
                if "Server" in headers:
                    server_header = headers["Server"]
                    if any(
                        server in server_header.lower()
                        for server in ["nginx", "apache", "iis"]
                    ):
                        results["warnings"].append(
                            f"{endpoint} discloses server information: {server_header}"
                        )

                # Check for HTTPS redirect
                if endpoint.startswith("http://") and response.status_code not in [
                    301,
                    302,
                    307,
                    308,
                ]:
                    results["warnings"].append(f"{endpoint} does not redirect to HTTPS")

            except requests.RequestException as e:
                results["warnings"].append(f"Could not test {endpoint}: {str(e)}")

        return results

    def test_api_security(self) -> Dict:
#        """Test API security"""
#        results = {"passed": [], "failed": [], "warnings": []}
#
#        api_endpoints = [
#            "http://localhost:3000/api/health",
#            "http://localhost:3000/api/status",
#        ]
#
#        for endpoint in api_endpoints:
#            try:
#                # Test rate limiting
#                rate_limit_test = True
#                for i in range(20):
#                    response = requests.get(endpoint, timeout=5)
#                    if response.status_code == 429:  # Too Many Requests
#                        results["passed"].append(f"{endpoint} has rate limiting")
#                        rate_limit_test = False
#                        break
#
#                if rate_limit_test:
#                    results["warnings"].append(f"{endpoint} may not have rate limiting")
#
#                # Test for SQL injection patterns (basic check)
#                sql_payloads = ["'", "1' OR '1'='1", "'; DROP TABLE users; --"]
#
#                for payload in sql_payloads:
#                    try:
#                        response = requests.get(f"{endpoint}?id={payload}", timeout=5)
#
#                        # Check for SQL error messages
#                        error_patterns = [
#                            "sql",
#                            "mysql",
#                            "postgresql",
#                            "oracle",
#                            "syntax error",
#                        ]
#                        response_text = response.text.lower()
#
#                        if any(pattern in response_text for pattern in error_patterns):
#                            results["failed"].append(
#                                f"{endpoint} may be vulnerable to SQL injection"
#                            )
#                            break
#                    except requests.RequestException:
#                        pass
#                else:
#                    results["passed"].append(
#                        f"{endpoint} appears protected against SQL injection"
#                    )
#
#                # Test for XSS patterns
#                xss_payloads = [
#                    "<script>alert('xss')</script>",
#                    "javascript:alert('xss')",
#                ]
#
#                for payload in xss_payloads:
#                    try:
#                        response = requests.get(f"{endpoint}?q={payload}", timeout=5)
#
#                        if payload in response.text:
#                            results["failed"].append(
#                                f"{endpoint} may be vulnerable to XSS"
#                            )
#                            break
#                    except requests.RequestException:
#                        pass
#                else:
#                    results["passed"].append(
#                        f"{endpoint} appears protected against XSS"
#                    )
#
#            except requests.RequestException as e:
#                results["warnings"].append(f"Could not test {endpoint}: {str(e)}")
#
#        return results
#
#    def test_authentication_security(self) -> Dict:
#        """Test authentication security"""
        results = {"passed": [], "failed": [], "warnings": []}

        # This would test authentication mechanisms
        # Implementation depends on specific authentication system

        results["warnings"].append("Authentication security tests need implementation")

        return results

    def test_compliance(self) -> Dict:
#        """Test compliance requirements"""
#        print("Testing compliance...")
#
#        results = {
#            "data_protection": self.test_data_protection(),
#            "audit_requirements": self.test_audit_requirements(),
#            "retention_policies": self.test_retention_policies(),
#        }
#
#        return results
#
#    def test_data_protection(self) -> Dict:
#        """Test data protection compliance"""
        results = {"passed": [], "failed": [], "warnings": []}

        # Test encryption in transit and at rest (already covered)
        results["passed"].append("Encryption tests covered in infrastructure security")

        # Test data classification
        results["warnings"].append(
            "Data classification compliance needs manual verification"
        )

        # Test access controls
        results["warnings"].append(
            "Access control compliance needs manual verification"
        )

        return results

    def test_audit_requirements(self) -> Dict:
#        """Test audit requirements compliance"""
#        results = {"passed": [], "failed": [], "warnings": []}
#
#        # Test audit logging (already covered)
#        results["passed"].append(
#            "Audit logging tests covered in infrastructure security"
#        )
#
#        # Test audit trail integrity
#        results["warnings"].append("Audit trail integrity needs manual verification")
#
#        return results
#
#    def test_retention_policies(self) -> Dict:
#        """Test data retention policies"""
        results = {"passed": [], "failed": [], "warnings": []}

        # Test log retention (already covered)
        results["passed"].append(
            "Log retention tests covered in infrastructure security"
        )

        # Test backup retention
        results["warnings"].append("Backup retention policies need manual verification")

        return results

    def test_vulnerabilities(self) -> Dict:
#        """Test for known vulnerabilities"""
#        print("Testing for vulnerabilities...")
#
#        results = {
#            "dependency_scanning": self.test_dependency_vulnerabilities(),
#            "infrastructure_scanning": self.test_infrastructure_vulnerabilities(),
#            "configuration_scanning": self.test_configuration_vulnerabilities(),
#        }
#
#        return results
#
#    def test_dependency_vulnerabilities(self) -> Dict:
#        """Test for dependency vulnerabilities"""
        results = {"passed": [], "failed": [], "warnings": []}

        # Test Node.js dependencies
        try:
            npm_audit = subprocess.run(
                ["npm", "audit", "--json"],
                capture_output=True,
                text=True,
                timeout=120,
                cwd="../../",
            )

            if npm_audit.returncode == 0:
                audit_data = json.loads(npm_audit.stdout)
                vulnerabilities = audit_data.get("vulnerabilities", {})

                high_vulns = sum(
                    1 for v in vulnerabilities.values() if v.get("severity") == "high"
                )
                critical_vulns = sum(
                    1
                    for v in vulnerabilities.values()
                    if v.get("severity") == "critical"
                )

                if critical_vulns > 0:
                    results["failed"].append(
                        f"Found {critical_vulns} critical npm vulnerabilities"
                    )
                elif high_vulns > 0:
                    results["warnings"].append(
                        f"Found {high_vulns} high npm vulnerabilities"
                    )
                else:
                    results["passed"].append(
                        "No high/critical npm vulnerabilities found"
                    )

        except (subprocess.TimeoutExpired, FileNotFoundError, json.JSONDecodeError):
            results["warnings"].append("Could not run npm audit")

        return results

    def test_infrastructure_vulnerabilities(self) -> Dict:
#        """Test infrastructure for vulnerabilities"""
#        results = {"passed": [], "failed": [], "warnings": []}
#
#        # This would integrate with vulnerability scanners
#        results["warnings"].append(
#            "Infrastructure vulnerability scanning needs integration with security tools"
#        )
#
#        return results
#
#    def test_configuration_vulnerabilities(self) -> Dict:
#        """Test configuration for vulnerabilities"""
        results = {"passed": [], "failed": [], "warnings": []}

        # Test for common misconfigurations
        results["warnings"].append(
            "Configuration vulnerability scanning needs implementation"
        )

        return results

    def generate_security_report(self, test_results: Dict) -> None:
#        """Generate comprehensive security report"""
#        report_file = f"security_report_{self.environment}_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.json"
#
#        with open(report_file, "w") as f:
#            json.dump(test_results, f, indent=2)
#
#        print(f"Security report generated: {report_file}")
#
#        # Generate summary
#        total_passed = 0
#        total_failed = 0
#        total_warnings = 0
#
#        def count_results(results):
#            nonlocal total_passed, total_failed, total_warnings
#            if isinstance(results, dict):
#                if "passed" in results:
#                    total_passed += len(results["passed"])
#                if "failed" in results:
#                    total_failed += len(results["failed"])
#                if "warnings" in results:
#                    total_warnings += len(results["warnings"])
#
#                for value in results.values():
#                    if isinstance(value, dict):
#                        count_results(value)
#
#        count_results(test_results["tests"])
#
#        print(f"\nSecurity Test Summary:")
#        print(f"Passed: {total_passed}")
#        print(f"Failed: {total_failed}")
#        print(f"Warnings: {total_warnings}")
#
#        if total_failed > 0:
#            print(f"\n❌ Security tests FAILED - {total_failed} critical issues found")
#            sys.exit(1)
#        elif total_warnings > 0:
#            print(
#                f"\n⚠️  Security tests PASSED with warnings - {total_warnings} issues to review"
#            )
#        else:
#            print(f"\n✅ All security tests PASSED")
#
#
#def main():
#    """Main function to run security tests"""
    import argparse

    parser = argparse.ArgumentParser(description="QuantumBallot Security Test Suite")
    parser.add_argument("--environment", default="test", help="Environment to test")
    parser.add_argument(
        "--test-type",
        choices=[
            "all",
            "infrastructure",
            "containers",
            "network",
            "application",
            "compliance",
            "vulnerabilities",
        ],
        default="all",
        help="Type of tests to run",
    )

    args = parser.parse_args()

    suite = SecurityTestSuite(args.environment)

    if args.test_type == "all":
        results = suite.run_all_tests()
    else:
        # Run specific test type
        test_method = getattr(suite, f"test_{args.test_type}_security")
        results = {args.test_type: test_method()}
        suite.generate_security_report(
            {
                "tests": results,
                "environment": args.environment,
                "timestamp": datetime.utcnow().isoformat(),
            }
        )


if __name__ == "__main__":
    main()
