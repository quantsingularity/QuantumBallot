# Configuration Guide

Complete configuration reference for all QuantumBallot components.

---

## Table of Contents

1. [Backend Configuration](#backend-configuration)
2. [Web Frontend Configuration](#web-frontend-configuration)
3. [Mobile Frontend Configuration](#mobile-frontend-configuration)
4. [Infrastructure Configuration](#infrastructure-configuration)
5. [Security Configuration](#security-configuration)

---

## Backend Configuration

### Environment Variables

All backend environment variables are defined in `backend/.env`.

| Option                  | Type   | Default                   | Description                                            | Where to set (env/file) |
| ----------------------- | ------ | ------------------------- | ------------------------------------------------------ | ----------------------- |
| `PORT`                  | number | `3000`                    | Server listening port                                  | `.env`                  |
| `NODE_ENV`              | string | `development`             | Environment mode (`development`, `production`, `test`) | `.env`                  |
| `JWT_SECRET`            | string | **required**              | JWT token signing secret (min 32 characters)           | `.env`                  |
| `ACCESS_TOKEN_SECRET`   | string | **required**              | Access token secret (min 32 characters)                | `.env`                  |
| `DB_PATH`               | string | `./data/QuantumBallot_db` | LevelDB database storage path                          | `.env`                  |
| `SECRET_KEY_IDENTIFIER` | string | **required**              | AES-256 key for identifier encryption (64 hex chars)   | `.env`                  |
| `SECRET_IV_IDENTIFIER`  | string | **required**              | AES-256 IV for identifier encryption (32 hex chars)    | `.env`                  |
| `SECRET_KEY_VOTES`      | string | **required**              | AES-256 key for vote encryption (64 hex chars)         | `.env`                  |
| `SECRET_IV_VOTES`       | string | **required**              | AES-256 IV for vote encryption (32 hex chars)          | `.env`                  |
| `MAILER_SERVICE`        | string | `gmail`                   | Email service provider (`gmail`, `smtp`)               | `.env`                  |
| `MAILER_HOST`           | string | `smtp.gmail.com`          | SMTP server hostname                                   | `.env`                  |
| `MAILER_PORT`           | number | `587`                     | SMTP server port (587 for TLS, 465 for SSL)            | `.env`                  |
| `MAILER_USER`           | string | **required**              | Email account username/address                         | `.env`                  |
| `MAILER_PASS`           | string | **required**              | Email account password or app-specific password        | `.env`                  |

### Example .env File

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# JWT Secrets (generate random 32+ character strings)
JWT_SECRET=your_jwt_secret_here_min_32_chars_long_random_string
ACCESS_TOKEN_SECRET=your_access_token_secret_here_min_32_chars_random

# Database
DB_PATH=./data/QuantumBallot_db

# Blockchain Encryption Keys
# Generate with: node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
SECRET_KEY_IDENTIFIER=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
SECRET_IV_IDENTIFIER=0123456789abcdef0123456789abcdef

# Vote Encryption Keys
SECRET_KEY_VOTES=fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210
SECRET_IV_VOTES=fedcba9876543210fedcba9876543210

# Email Configuration
MAILER_SERVICE=gmail
MAILER_HOST=smtp.gmail.com
MAILER_PORT=587
MAILER_USER=your_email@gmail.com
MAILER_PASS=your_app_specific_password
```

### Generating Secure Keys

```bash
# Generate 32-byte (64 hex chars) encryption keys
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Generate 16-byte (32 hex chars) initialization vectors
node -e "console.log(require('crypto').randomBytes(16).toString('hex'))"

# Generate JWT secret (32+ characters)
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

### CORS Configuration

**File**: `backend/src/index.ts` and `backend/src/config/allowedOrigins.ts`

```typescript
// Allowed origins for CORS
const allowedOrigins = [
  "http://localhost:3007",
  "http://localhost:3010",
  "http://localhost:5173", // Vite default
  "http://127.0.0.1:5500",
  "http://localhost:3000",
  // Add production URLs here
  "https://your-production-domain.com",
];
```

### TypeScript Configuration

**File**: `backend/tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

---

## Web Frontend Configuration

### Environment Variables

**File**: `web-frontend/.env`

| Option            | Type   | Default                     | Description          | Where to set (env/file) |
| ----------------- | ------ | --------------------------- | -------------------- | ----------------------- |
| `VITE_API_URL`    | string | `http://localhost:3000/api` | Backend API base URL | `.env`                  |
| `VITE_SOCKET_URL` | string | `http://localhost:3000`     | WebSocket server URL | `.env`                  |
| `VITE_APP_NAME`   | string | `QuantumBallot`             | Application name     | `.env`                  |
| `VITE_ENV`        | string | `development`               | Environment mode     | `.env`                  |

### Example .env File

```env
# API Configuration
VITE_API_URL=http://localhost:3000/api
VITE_SOCKET_URL=http://localhost:3000

# App Configuration
VITE_APP_NAME=QuantumBallot
VITE_ENV=development

# Production Example:
# VITE_API_URL=https://api.quantumballot.com/api
# VITE_SOCKET_URL=https://api.quantumballot.com
# VITE_ENV=production
```

### Vite Configuration

**File**: `web-frontend/vite.config.ts`

```typescript
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  server: {
    port: 5173,
    proxy: {
      "/api": {
        target: "http://localhost:3000",
        changeOrigin: true,
      },
    },
  },
});
```

### Tailwind Configuration

**File**: `web-frontend/tailwind.config.js`

```javascript
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {...},
        secondary: {...}
      }
    },
  },
  plugins: [],
}
```

---

## Mobile Frontend Configuration

### Environment Variables

**File**: `mobile-frontend/.env`

| Option       | Type   | Default       | Description                                           | Where to set (env/file) |
| ------------ | ------ | ------------- | ----------------------------------------------------- | ----------------------- |
| `API_URL`    | string | **required**  | Backend API URL (use local network IP, not localhost) | `.env`                  |
| `SOCKET_URL` | string | **required**  | WebSocket server URL                                  | `.env`                  |
| `ENV`        | string | `development` | Environment mode                                      | `.env`                  |

### Example .env File

```env
# API Configuration
# Use your computer's local IP address, not localhost
API_URL=http://192.168.1.100:3000/api
SOCKET_URL=http://192.168.1.100:3000

# Environment
ENV=development

# Production Example:
# API_URL=https://api.quantumballot.com/api
# SOCKET_URL=https://api.quantumballot.com
# ENV=production
```

### Finding Your Local IP Address

```bash
# macOS/Linux
ifconfig | grep "inet " | grep -v 127.0.0.1

# Windows
ipconfig | findstr /i "IPv4"

# Common format: 192.168.1.x or 10.0.0.x
```

### App Configuration

**File**: `mobile-frontend/app.json`

```json
{
  "expo": {
    "name": "QuantumBallot",
    "slug": "quantumballot-mobile",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#ffffff"
    },
    "ios": {
      "supportsTablet": true,
      "bundleIdentifier": "com.quantumballot.mobile"
    },
    "android": {
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png",
        "backgroundColor": "#FFFFFF"
      },
      "package": "com.quantumballot.mobile"
    }
  }
}
```

### EAS Configuration

**File**: `mobile-frontend/eas.json`

```json
{
  "cli": {
    "version": ">= 3.0.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal"
    },
    "production": {}
  },
  "submit": {
    "production": {}
  }
}
```

---

## Infrastructure Configuration

### Docker Configuration

**File**: `infrastructure/docker/docker-compose.yml`

```yaml
version: "3.8"

services:
  backend:
    build:
      context: ../../backend
      dockerfile: ../infrastructure/docker/Dockerfile.backend
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - PORT=3000
      - DB_PATH=/data/QuantumBallot_db
    env_file:
      - ../../backend/.env
    volumes:
      - blockchain-data:/data
    restart: unless-stopped

  web-frontend:
    build:
      context: ../../web-frontend
      dockerfile: ../infrastructure/docker/Dockerfile.web
    ports:
      - "80:80"
    depends_on:
      - backend
    restart: unless-stopped

volumes:
  blockchain-data:
```

### Kubernetes Configuration

**File**: `infrastructure/kubernetes/backend-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: quantumballot-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: quantumballot-backend
  template:
    metadata:
      labels:
        app: quantumballot-backend
    spec:
      containers:
        - name: backend
          image: quantumballot/backend:latest
          ports:
            - containerPort: 3000
          env:
            - name: NODE_ENV
              value: "production"
            - name: PORT
              value: "3000"
          envFrom:
            - secretRef:
                name: quantumballot-secrets
          volumeMounts:
            - name: blockchain-storage
              mountPath: /data
      volumes:
        - name: blockchain-storage
          persistentVolumeClaim:
            claimName: blockchain-pvc
```

### Terraform Configuration

**File**: `infrastructure/terraform/main.tf`

```hcl
provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "quantumballot_backend" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "QuantumBallot-Backend"
    Environment = var.environment
  }
}

variable "aws_region" {
  default = "us-east-1"
}

variable "environment" {
  default = "production"
}
```

### Ansible Configuration

**File**: `infrastructure/ansible/site.yml`

```yaml
---
- name: Deploy QuantumBallot
  hosts: all
  become: yes

  roles:
    - common
    - backend
    - frontend_web

  vars:
    node_version: "18.x"
    app_user: "quantumballot"
    app_dir: "/opt/quantumballot"
```

---

## Security Configuration

### SSL/TLS Configuration

**Nginx Configuration** (for production):

```nginx
server {
    listen 443 ssl http2;
    server_name quantumballot.com;

    ssl_certificate /etc/ssl/certs/quantumballot.crt;
    ssl_certificate_key /etc/ssl/private/quantumballot.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Firewall Rules

```bash
# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow backend (internal only)
sudo ufw allow from 10.0.0.0/8 to any port 3000

# Enable firewall
sudo ufw enable
```

### Secret Management

**Using environment variables** (development):

```bash
export JWT_SECRET="$(openssl rand -base64 32)"
```

**Using secret management** (production):

- AWS Secrets Manager
- HashiCorp Vault
- Kubernetes Secrets

---

## Performance Tuning

### Node.js Performance

```bash
# Set Node.js memory limit
export NODE_OPTIONS="--max-old-space-size=4096"

# Enable production optimizations
export NODE_ENV=production
```

### Database Optimization

```javascript
// LevelDB configuration
const db = level(DB_PATH, {
  createIfMissing: true,
  cacheSize: 16 * 1024 * 1024, // 16 MB cache
  writeBufferSize: 8 * 1024 * 1024, // 8 MB write buffer
});
```

---

## Logging Configuration

### Backend Logging

```typescript
// Configure Winston logger
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || "info",
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: "error.log", level: "error" }),
    new winston.transports.File({ filename: "combined.log" }),
  ],
});
```

---

_For installation instructions, see [INSTALLATION.md](INSTALLATION.md). For deployment, see [DEPLOYMENT.md](DEPLOYMENT.md)._
