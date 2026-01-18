# CLI Reference

Command-line interface tools and scripts for QuantumBallot.

---

## Table of Contents

1. [Overview](#overview)
2. [NPM Scripts](#npm-scripts)
3. [Shell Scripts](#shell-scripts)
4. [Development Workflow](#development-workflow)
5. [Deployment Scripts](#deployment-scripts)

---

## Overview

QuantumBallot provides several CLI tools and scripts for:

- Development workflow automation
- Build and deployment
- Testing and linting
- Environment setup
- Documentation generation

---

## NPM Scripts

### Backend Scripts

All backend scripts are run from the `backend/` directory:

| Command                 | Arguments | Description                               | Example                               |
| ----------------------- | --------- | ----------------------------------------- | ------------------------------------- |
| `npm run dev`           | -         | Start development server with auto-reload | `cd backend && npm run dev`           |
| `npm start`             | -         | Start production server                   | `cd backend && npm start`             |
| `npm run build`         | -         | Compile TypeScript to JavaScript          | `cd backend && npm run build`         |
| `npm test`              | -         | Run all tests with Jest                   | `cd backend && npm test`              |
| `npm run test:coverage` | -         | Run tests with coverage report            | `cd backend && npm run test:coverage` |
| `npm run test:watch`    | -         | Run tests in watch mode                   | `cd backend && npm run test:watch`    |

**Examples**:

```bash
# Development
cd backend
npm run dev
# Output: ✓ QuantumBallot Backend Server running on: http://localhost:3000

# Production build
npm run build
npm start

# Testing with coverage
npm run test:coverage
# Output: Test coverage report in coverage/ directory
```

---

### Web Frontend Scripts

All web frontend scripts are run from the `web-frontend/` directory:

| Command           | Arguments | Description                   | Example                              |
| ----------------- | --------- | ----------------------------- | ------------------------------------ |
| `npm run dev`     | -         | Start Vite development server | `cd web-frontend && npm run dev`     |
| `npm run build`   | -         | Build production bundle       | `cd web-frontend && npm run build`   |
| `npm run preview` | -         | Preview production build      | `cd web-frontend && npm run preview` |
| `npm test`        | -         | Run Vitest tests              | `cd web-frontend && npm test`        |
| `npm run lint`    | -         | Run ESLint code linter        | `cd web-frontend && npm run lint`    |

**Examples**:

```bash
# Development
cd web-frontend
npm run dev
# Output: VITE ready in 500ms
#         ➜  Local:   http://localhost:5173/

# Production build
npm run build
# Output: dist/ ready for deployment

# Run tests
npm test
```

---

### Mobile Frontend Scripts

All mobile frontend scripts are run from the `mobile-frontend/` directory:

| Command                 | Arguments | Description                         | Example                                       |
| ----------------------- | --------- | ----------------------------------- | --------------------------------------------- |
| `npm start`             | -         | Start Expo development server       | `cd mobile-frontend && npm start`             |
| `npm run android`       | -         | Start on Android emulator/device    | `cd mobile-frontend && npm run android`       |
| `npm run ios`           | -         | Start on iOS simulator (macOS only) | `cd mobile-frontend && npm run ios`           |
| `npm run web`           | -         | Start web version (experimental)    | `cd mobile-frontend && npm run web`           |
| `npm test`              | -         | Run Jest tests                      | `cd mobile-frontend && npm test`              |
| `npm run test:watch`    | -         | Run tests in watch mode             | `cd mobile-frontend && npm run test:watch`    |
| `npm run test:coverage` | -         | Run tests with coverage             | `cd mobile-frontend && npm run test:coverage` |
| `npm run lint`          | -         | Run ESLint linter                   | `cd mobile-frontend && npm run lint`          |
| `npm run format`        | -         | Format code with Prettier           | `cd mobile-frontend && npm run format`        |

**Examples**:

```bash
# Start Expo
cd mobile-frontend
npm start
# Output: QR code to scan with Expo Go app

# Run on Android
npm run android
# Opens app on connected Android device or emulator

# Run tests with coverage
npm run test:coverage
```

---

## Shell Scripts

QuantumBallot includes several shell scripts in the `scripts/` directory for automation.

### Main Script

**Location**: `scripts/main.sh`

Main entry point for common tasks.

```bash
# Usage
./scripts/main.sh [command] [options]

# Available commands
./scripts/main.sh setup      # Setup environment
./scripts/main.sh build      # Build all components
./scripts/main.sh test       # Run all tests
./scripts/main.sh deploy     # Deploy to production
```

---

### Setup Script

**Location**: `scripts/setup.sh`

Setup development environment.

| Command                              | Arguments         | Description              | Example                              |
| ------------------------------------ | ----------------- | ------------------------ | ------------------------------------ |
| `./scripts/setup.sh`                 | -                 | Install all dependencies | `./scripts/setup.sh`                 |
| `./scripts/setup.sh --skip-backend`  | `--skip-backend`  | Skip backend setup       | `./scripts/setup.sh --skip-backend`  |
| `./scripts/setup.sh --skip-frontend` | `--skip-frontend` | Skip frontend setup      | `./scripts/setup.sh --skip-frontend` |

**Example**:

```bash
# Full setup
./scripts/setup.sh
# Output:
# ✓ Installing backend dependencies...
# ✓ Installing web-frontend dependencies...
# ✓ Installing mobile-frontend dependencies...
# ✓ Setup complete!

# Skip backend
./scripts/setup.sh --skip-backend
```

---

### Build Script

**Location**: `scripts/build.sh`

Build all components for production.

```bash
# Build all
./scripts/build.sh

# Build specific component
./scripts/build.sh backend
./scripts/build.sh web-frontend
./scripts/build.sh mobile-frontend
```

**Example**:

```bash
./scripts/build.sh
# Output:
# Building backend...
# ✓ Backend build complete
# Building web-frontend...
# ✓ Web frontend build complete
# Building mobile-frontend...
# ✓ Mobile frontend build complete
```

---

### Development Workflow Script

**Location**: `scripts/dev_workflow.sh`

Comprehensive development workflow automation.

| Command                             | Arguments | Description                   | Example                                  |
| ----------------------------------- | --------- | ----------------------------- | ---------------------------------------- |
| `./scripts/dev_workflow.sh start`   | -         | Start all development servers | `./scripts/dev_workflow.sh start`        |
| `./scripts/dev_workflow.sh stop`    | -         | Stop all development servers  | `./scripts/dev_workflow.sh stop`         |
| `./scripts/dev_workflow.sh restart` | -         | Restart all servers           | `./scripts/dev_workflow.sh restart`      |
| `./scripts/dev_workflow.sh status`  | -         | Check server status           | `./scripts/dev_workflow.sh status`       |
| `./scripts/dev_workflow.sh logs`    | component | View logs for component       | `./scripts/dev_workflow.sh logs backend` |

**Example**:

```bash
# Start all servers
./scripts/dev_workflow.sh start
# Output:
# Starting backend server...
# Starting web frontend server...
# Starting mobile frontend server...
# ✓ All servers started

# Check status
./scripts/dev_workflow.sh status
# Output:
# Backend: Running (PID: 12345)
# Web Frontend: Running (PID: 12346)
# Mobile Frontend: Running (PID: 12347)

# View backend logs
./scripts/dev_workflow.sh logs backend
```

---

### Deployment Script

**Location**: `scripts/deployment.sh`

Deploy to production environments.

| Command                              | Arguments | Description              | Example                              |
| ------------------------------------ | --------- | ------------------------ | ------------------------------------ |
| `./scripts/deployment.sh staging`    | -         | Deploy to staging        | `./scripts/deployment.sh staging`    |
| `./scripts/deployment.sh production` | -         | Deploy to production     | `./scripts/deployment.sh production` |
| `./scripts/deployment.sh rollback`   | -         | Rollback last deployment | `./scripts/deployment.sh rollback`   |

**Example**:

```bash
# Deploy to staging
./scripts/deployment.sh staging
# Output:
# Building production bundles...
# Pushing to staging environment...
# Running database migrations...
# ✓ Deployment complete

# Deploy to production
./scripts/deployment.sh production
# (Requires confirmation)
# Deploy to production? (yes/no): yes
# ✓ Production deployment complete
```

---

### Lint All Script

**Location**: `scripts/lint-all.sh`

Run linters on all components.

```bash
# Lint all
./scripts/lint-all.sh

# Lint and fix
./scripts/lint-all.sh --fix
```

**Example**:

```bash
./scripts/lint-all.sh
# Output:
# Linting backend...
# ✓ Backend: 0 errors, 0 warnings
# Linting web-frontend...
# ✓ Web frontend: 0 errors, 0 warnings
# Linting mobile-frontend...
# ✓ Mobile frontend: 0 errors, 0 warnings
```

---

### Documentation Generator

**Location**: `scripts/documentation_generator.sh`

Generate project documentation.

```bash
# Generate all documentation
./scripts/documentation_generator.sh

# Generate specific docs
./scripts/documentation_generator.sh api
./scripts/documentation_generator.sh architecture
```

**Example**:

```bash
./scripts/documentation_generator.sh
# Output:
# Generating API documentation...
# Generating architecture diagrams...
# Generating user manual...
# ✓ Documentation generated in docs/
```

---

### Environment Setup Script

**Location**: `scripts/setup_environment.sh`

Setup environment variables and configuration.

```bash
# Interactive setup
./scripts/setup_environment.sh

# Non-interactive (use defaults)
./scripts/setup_environment.sh --default
```

**Example**:

```bash
./scripts/setup_environment.sh
# Output:
# Setting up QuantumBallot environment...
# Enter backend port [3000]: 3000
# Enter JWT secret (min 32 chars): ********************************
# Generate encryption keys? (yes/no): yes
# ✓ Environment setup complete
# Configuration saved to:
#   - backend/.env
#   - web-frontend/.env
#   - mobile-frontend/.env
```

---

### CI/CD Helper Script

**Location**: `scripts/ci_cd_helper.sh`

Helper script for CI/CD pipelines.

| Command                            | Arguments   | Description           | Example                                             |
| ---------------------------------- | ----------- | --------------------- | --------------------------------------------------- |
| `./scripts/ci_cd_helper.sh test`   | -           | Run all tests         | `./scripts/ci_cd_helper.sh test`                    |
| `./scripts/ci_cd_helper.sh build`  | -           | Build for CI          | `./scripts/ci_cd_helper.sh build`                   |
| `./scripts/ci_cd_helper.sh deploy` | environment | Deploy to environment | `./scripts/ci_cd_helper.sh deploy staging`          |
| `./scripts/ci_cd_helper.sh notify` | message     | Send notification     | `./scripts/ci_cd_helper.sh notify "Build complete"` |

**Example**:

```bash
# In CI/CD pipeline
./scripts/ci_cd_helper.sh test
./scripts/ci_cd_helper.sh build
./scripts/ci_cd_helper.sh deploy production
```

---

## Development Workflow

### Full Development Setup

```bash
# 1. Clone and setup
git clone https://github.com/quantsingularity/QuantumBallot.git
cd QuantumBallot
./scripts/setup.sh

# 2. Configure environment
./scripts/setup_environment.sh

# 3. Start development servers
./scripts/dev_workflow.sh start

# 4. Check status
./scripts/dev_workflow.sh status

# 5. View logs
./scripts/dev_workflow.sh logs backend
```

---

### Testing Workflow

```bash
# Run all tests
./scripts/lint-all.sh
cd backend && npm test
cd ../web-frontend && npm test
cd ../mobile-frontend && npm test

# Or use main script
./scripts/main.sh test
```

---

### Build and Deploy Workflow

```bash
# 1. Build all components
./scripts/build.sh

# 2. Run tests
./scripts/main.sh test

# 3. Deploy to staging
./scripts/deployment.sh staging

# 4. Verify staging
# (Manual verification)

# 5. Deploy to production
./scripts/deployment.sh production
```

---

## Deployment Scripts

### Docker Deployment

```bash
# Build and run with Docker Compose
docker-compose up --build

# Run in detached mode
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f backend
```

---

### Kubernetes Deployment

```bash
# Apply Kubernetes configs
kubectl apply -f infrastructure/kubernetes/

# Check deployment status
kubectl get pods
kubectl get services

# View logs
kubectl logs -f deployment/quantumballot-backend
```

---

## Script Options and Flags

### Common Flags

| Flag           | Description                          | Applicable Scripts   |
| -------------- | ------------------------------------ | -------------------- |
| `--help`       | Show help message                    | All scripts          |
| `--verbose`    | Verbose output                       | Most scripts         |
| `--quiet`      | Minimal output                       | Most scripts         |
| `--dry-run`    | Simulate without executing           | Deployment scripts   |
| `--skip-tests` | Skip running tests                   | Build/deploy scripts |
| `--force`      | Force operation (skip confirmations) | Deployment scripts   |

---

## Environment Variables for Scripts

Scripts respect these environment variables:

```bash
# General
QUANTUMBALLOT_ENV=development|staging|production
QUANTUMBALLOT_LOG_LEVEL=debug|info|warn|error

# Deployment
DEPLOY_TARGET=local|staging|production
DEPLOY_CONFIRM=yes|no  # Skip confirmation prompts

# Build
BUILD_TARGET=development|production
BUILD_CLEAN=yes|no  # Clean before build
```

**Example**:

```bash
# Deploy to staging without confirmation
DEPLOY_CONFIRM=yes ./scripts/deployment.sh staging
```

---

## Troubleshooting CLI Issues

### Scripts Not Executable

```bash
# Make scripts executable
chmod +x scripts/*.sh
```

### Node/NPM Not Found

```bash
# Ensure Node.js is in PATH
which node
which npm

# If not found, reinstall Node.js or update PATH
```

### Permission Denied

```bash
# Fix permissions
sudo chown -R $USER:$GROUP .
```

---

_For more information on usage, see [USAGE.md](USAGE.md). For API details, see [API.md](API.md)._
