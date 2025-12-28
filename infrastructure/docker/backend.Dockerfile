# Dockerfile for QuantumBallot Backend API
# Implements financial-grade security best practices and compliance requirements

# Use specific version with security patches
FROM node:20.11.1-alpine3.19 AS builder

# Set build arguments for security scanning
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

# Add metadata labels for compliance
LABEL maintainer="QuantumBallot Security Team" \
      org.opencontainers.image.title="QuantumBallot Backend API" \
      org.opencontainers.image.description="Secure backend API for QuantumBallot election platform" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.vendor="QuantumBallot" \
      security.scan.required="true" \
      compliance.level="financial-grade"

# Install security updates and required packages
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        dumb-init \
        ca-certificates \
        tzdata && \
    # Remove package cache
    rm -rf /var/cache/apk/* && \
    # Create non-root user
    addgroup -g 1001 -S nodegroup && \
    adduser -S -D -H -u 1001 -s /sbin/nologin -G nodegroup nodeuser

# Set secure environment variables
ENV NODE_ENV=production \
    NODE_PORT=3000 \
    SERVER_PORT=3002 \
    DIR=/usr/app \
    NPM_CONFIG_CACHE=/tmp/.npm \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    NPM_CONFIG_FUND=false \
    NPM_CONFIG_AUDIT_LEVEL=moderate \
    # Security headers
    HELMET_ENABLED=true \
    RATE_LIMIT_ENABLED=true \
    # Logging configuration
    LOG_LEVEL=info \
    LOG_FORMAT=json \
    # Health check configuration
    HEALTH_CHECK_ENABLED=true

# Create application directory with proper permissions
WORKDIR ${DIR}
RUN chown -R nodeuser:nodegroup ${DIR}

# Switch to non-root user for dependency installation
USER nodeuser

# Copy package files with proper ownership
COPY --chown=nodeuser:nodegroup package*.json ./

# Verify package integrity and install dependencies
RUN npm ci --only=production --no-optional --no-audit --no-fund && \
    # Install development dependencies for build
    npm ci --only=development --no-optional --no-audit --no-fund && \
    # Install global dependencies with specific versions
    npm install -g typescript@5.3.3 && \
    # Clear npm cache
    npm cache clean --force

# Copy source code with proper ownership
COPY --chown=nodeuser:nodegroup . .

# Build the application with security checks
RUN npm run lint && \
    npm run security-audit && \
    npm run build && \
    # Remove development dependencies
    npm prune --production && \
    # Remove source files after build
    rm -rf src/ tests/ *.ts tsconfig.json .eslintrc.js

# Production stage with minimal attack surface
FROM node:20.11.1-alpine3.19

# Add metadata labels
LABEL maintainer="QuantumBallot Security Team" \
      org.opencontainers.image.title="QuantumBallot Backend API" \
      org.opencontainers.image.description="Secure backend API for QuantumBallot election platform" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      security.scan.required="true" \
      compliance.level="financial-grade"

# Install only essential security updates
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        dumb-init \
        ca-certificates \
        tzdata \
        curl && \
    # Remove package cache
    rm -rf /var/cache/apk/* && \
    # Create non-root user with minimal privileges
    addgroup -g 1001 -S nodegroup && \
    adduser -S -D -H -u 1001 -s /sbin/nologin -G nodegroup nodeuser && \
    # Remove unnecessary packages and files
    rm -rf /usr/share/man/* \
           /usr/share/doc/* \
           /var/cache/apk/* \
           /tmp/* \
           /var/tmp/*

# Set secure environment variables
ENV NODE_ENV=production \
    NODE_PORT=3000 \
    SERVER_PORT=3002 \
    DIR=/usr/app \
    # Security configurations
    NODE_OPTIONS="--max-old-space-size=512 --no-warnings" \
    # Disable unnecessary features
    NODE_DISABLE_COLORS=1 \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    NPM_CONFIG_FUND=false

# Create application directory with restricted permissions
WORKDIR ${DIR}
RUN chown -R nodeuser:nodegroup ${DIR} && \
    chmod 750 ${DIR}

# Switch to non-root user
USER nodeuser

# Copy only production files from builder stage
COPY --from=builder --chown=nodeuser:nodegroup ${DIR}/build ./build
COPY --from=builder --chown=nodeuser:nodegroup ${DIR}/package*.json ./
COPY --from=builder --chown=nodeuser:nodegroup ${DIR}/node_modules ./node_modules

# Create health check script
COPY --chown=nodeuser:nodegroup <<EOF /usr/app/healthcheck.js
const http = require('http');
const options = {
  host: 'localhost',
  port: process.env.NODE_PORT || 3000,
  path: '/health',
  timeout: 2000,
  method: 'GET'
};

const request = http.request(options, (res) => {
  console.log(\`Health check status: \${res.statusCode}\`);
  if (res.statusCode === 200) {
    process.exit(0);
  } else {
    process.exit(1);
  }
});

request.on('error', (err) => {
  console.log('Health check failed:', err.message);
  process.exit(1);
});

request.on('timeout', () => {
  console.log('Health check timeout');
  request.destroy();
  process.exit(1);
});

request.end();
EOF

# Set file permissions
RUN chmod 644 package*.json && \
    chmod -R 644 build/ && \
    chmod 755 healthcheck.js && \
    # Remove write permissions from application directory
    chmod -R a-w ${DIR}/build ${DIR}/node_modules

# Expose only the necessary port
EXPOSE ${NODE_PORT}

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD node /usr/app/healthcheck.js

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start the application with security considerations
CMD ["node", "--max-old-space-size=512", "--no-warnings", "build/network.js"]

# Security scan instructions
# RUN trivy filesystem --exit-code 1 --no-progress --severity HIGH,CRITICAL .
# RUN grype . --fail-on high
