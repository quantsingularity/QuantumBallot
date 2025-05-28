# Chainocracy Infrastructure

This directory contains the infrastructure configuration and deployment resources for the Chainocracy project, a full-stack Web and Mobile application for American elections using Blockchain Technology. The infrastructure components are organized into several specialized subdirectories, each focusing on different aspects of deployment, orchestration, and infrastructure management.

## Overview

The infrastructure directory provides all necessary configurations and scripts to deploy, manage, and scale the Chainocracy application across various environments. It follows infrastructure-as-code principles, ensuring consistent, reproducible deployments and environment configurations.

## Directory Structure

The infrastructure is organized into the following subdirectories:

### Ansible

The `ansible` directory contains configuration management and application deployment resources using Ansible, an open-source automation tool. Key components include:

- `ansible.cfg`: Configuration file for Ansible settings
- `hosts`: Inventory file defining target servers and their groupings
- `roles/`: Directory containing reusable Ansible roles for various system configurations
- `site.yml`: Main playbook that orchestrates the application deployment

Ansible is primarily used for server provisioning, configuration management, and application deployment across different environments.

### Docker

The `docker` directory contains Docker-related configuration files for containerizing the Chainocracy application components:

- `backend.Dockerfile`: Dockerfile for building the backend API container
- `frontend-web.Dockerfile`: Dockerfile for building the web frontend container
- `docker-compose.yml`: Composition file for local development and testing
- `nginx.conf`: Nginx configuration for the web server container

These Docker configurations enable consistent development environments and simplified deployment processes.

### Kubernetes

The `kubernetes` directory contains Kubernetes manifests for orchestrating containerized applications in production and staging environments:

- `base/`: Directory containing base Kubernetes configurations
- `overlays/`: Directory containing environment-specific overlays using Kustomize

The Kubernetes configurations follow the Kustomize pattern, allowing for environment-specific customizations while maintaining a common base configuration.

### Terraform

The `terraform` directory contains infrastructure-as-code configurations using Terraform for provisioning cloud resources:

- `environments/`: Directory containing environment-specific Terraform configurations
- `modules/`: Directory containing reusable Terraform modules
- `providers.tf`: Provider configuration for cloud services

Terraform is used to provision and manage cloud infrastructure resources across different environments.

## Usage

### Local Development

For local development using Docker:

1. Navigate to the `docker` directory
2. Run the following command to start all services:
   ```
   docker-compose up -d
   ```
3. Access the application at http://localhost:8080

### Deployment

#### Using Ansible

1. Update the `hosts` file with your target servers
2. Run the deployment playbook:
   ```
   ansible-playbook -i hosts site.yml
   ```

#### Using Kubernetes

1. Ensure you have `kubectl` and `kustomize` installed
2. Select the appropriate environment overlay:
   ```
   kubectl apply -k kubernetes/overlays/[environment]
   ```
   Where `[environment]` is one of: dev, staging, production

#### Using Terraform

1. Navigate to the appropriate environment directory:
   ```
   cd terraform/environments/[environment]
   ```
2. Initialize and apply the Terraform configuration:
   ```
   terraform init
   terraform apply
   ```

## Best Practices

When working with the infrastructure code:

1. Always test changes in development or staging environments before applying to production
2. Keep secrets and sensitive information out of version control
3. Use environment variables or secret management solutions for credentials
4. Document any significant changes to the infrastructure configuration
5. Follow the principle of immutable infrastructure where possible
6. Use infrastructure-as-code for all resource provisioning to ensure consistency

## Requirements

- Docker and Docker Compose for local development
- Ansible 2.9+ for configuration management
- Kubernetes 1.20+ for container orchestration
- Terraform 1.0+ for infrastructure provisioning
- Access to target cloud provider accounts (AWS, GCP, or Azure)

## Related Resources

- For application-specific configuration, refer to the `backend-api` and `web-frontend` directories
- For deployment scripts, check the `scripts` directory at the root of the repository
- For detailed system architecture, consult the documentation in the `docs` directory
