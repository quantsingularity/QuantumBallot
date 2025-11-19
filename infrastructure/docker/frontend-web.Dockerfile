# Enhanced Dockerfile for Chainocracy Web Frontend
# Implements financial-grade security best practices with hardened Nginx

# Build stage with security enhancements
FROM node:20.11.1-alpine3.19 AS builder

# Set build arguments for security scanning
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
ARG VITE_API_URL=/api

# Add metadata labels for compliance
LABEL maintainer="Chainocracy Security Team" \
      org.opencontainers.image.title="Chainocracy Web Frontend" \
      org.opencontainers.image.description="Secure web frontend for Chainocracy election platform" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.vendor="Chainocracy" \
      security.scan.required="true" \
      compliance.level="financial-grade"

# Install security updates and build tools
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        ca-certificates \
        tzdata \
        git && \
    # Remove package cache
    rm -rf /var/cache/apk/* && \
    # Create non-root user
    addgroup -g 1001 -S nodegroup && \
    adduser -S -D -H -u 1001 -s /sbin/nologin -G nodegroup nodeuser

# Set secure build environment
ENV NODE_ENV=production \
    NPM_CONFIG_CACHE=/tmp/.npm \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    NPM_CONFIG_FUND=false \
    NPM_CONFIG_AUDIT_LEVEL=moderate \
    VITE_API_URL=${VITE_API_URL} \
    # Security build flags
    VITE_SECURITY_HEADERS=true \
    VITE_CSP_ENABLED=true \
    VITE_HSTS_ENABLED=true

# Create application directory with proper permissions
WORKDIR /app
RUN chown -R nodeuser:nodegroup /app

# Switch to non-root user
USER nodeuser

# Copy package files with proper ownership
COPY --chown=nodeuser:nodegroup web-frontend/package*.json ./

# Verify package integrity and install dependencies
RUN npm ci --only=production --no-optional --no-audit --no-fund && \
    # Install development dependencies for build
    npm ci --only=development --no-optional --no-audit --no-fund && \
    # Clear npm cache
    npm cache clean --force

# Copy source code with proper ownership
COPY --chown=nodeuser:nodegroup web-frontend/ .

# Build the application with security checks
RUN npm run lint && \
    npm run security-audit && \
    npm run type-check && \
    npm run build && \
    # Verify build output
    ls -la dist/ && \
    # Remove source files and development dependencies
    rm -rf src/ public/ node_modules/ *.ts *.js *.json .eslintrc* vite.config* tsconfig*

# Production stage with hardened Nginx
FROM nginx:1.25.3-alpine

# Add metadata labels
LABEL maintainer="Chainocracy Security Team" \
      org.opencontainers.image.title="Chainocracy Web Frontend" \
      org.opencontainers.image.description="Secure web frontend for Chainocracy election platform" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      security.scan.required="true" \
      compliance.level="financial-grade"

# Install security updates and remove unnecessary packages
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        ca-certificates \
        tzdata \
        curl && \
    # Remove unnecessary packages and files
    apk del --purge \
        wget \
        tar \
        gzip && \
    rm -rf /var/cache/apk/* \
           /usr/share/man/* \
           /usr/share/doc/* \
           /tmp/* \
           /var/tmp/* \
           /etc/nginx/conf.d/default.conf

# Create non-root user for Nginx
RUN addgroup -g 1001 -S nginxgroup && \
    adduser -S -D -H -u 1001 -s /sbin/nologin -G nginxgroup nginxuser && \
    # Create necessary directories with proper permissions
    mkdir -p /var/cache/nginx/client_temp \
             /var/cache/nginx/proxy_temp \
             /var/cache/nginx/fastcgi_temp \
             /var/cache/nginx/uwsgi_temp \
             /var/cache/nginx/scgi_temp \
             /var/log/nginx \
             /var/run && \
    # Set proper ownership and permissions
    chown -R nginxuser:nginxgroup /var/cache/nginx \
                                  /var/log/nginx \
                                  /var/run \
                                  /usr/share/nginx/html && \
    chmod -R 755 /var/cache/nginx \
                 /var/log/nginx \
                 /usr/share/nginx/html && \
    chmod 644 /var/run

# Copy static assets from builder stage with proper ownership
COPY --from=builder --chown=nginxuser:nginxgroup /app/dist /usr/share/nginx/html

# Create enhanced Nginx configuration with security headers
COPY --chown=nginxuser:nginxgroup <<EOF /etc/nginx/nginx.conf
# Enhanced Nginx configuration for financial-grade security

user nginxuser;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

# Security settings
worker_rlimit_nofile 65535;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

    # Content Security Policy
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self' https:; frame-ancestors 'none';" always;

    # Hide Nginx version
    server_tokens off;

    # Logging format
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for" '
                    'rt=\$request_time uct="\$upstream_connect_time" '
                    'uht="\$upstream_header_time" urt="\$upstream_response_time"';

    access_log /var/log/nginx/access.log main;

    # Performance settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 1m;
    client_body_timeout 10s;
    client_header_timeout 10s;
    send_timeout 10s;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;

    # Rate limiting
    limit_req_zone \$binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone \$binary_remote_addr zone=static:10m rate=30r/s;

    server {
        listen 8080;
        server_name _;
        root /usr/share/nginx/html;
        index index.html;

        # Security settings
        location ~ /\. {
            deny all;
            access_log off;
            log_not_found off;
        }

        location ~* \.(txt|log|conf)$ {
            deny all;
            access_log off;
            log_not_found off;
        }

        # Static files with caching
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            limit_req zone=static burst=20 nodelay;
            expires 1y;
            add_header Cache-Control "public, immutable";
            access_log off;
        }

        # API proxy with rate limiting
        location /api/ {
            limit_req zone=api burst=5 nodelay;
            proxy_pass http://backend:3000/;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            proxy_connect_timeout 5s;
            proxy_send_timeout 10s;
            proxy_read_timeout 10s;
        }

        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }

        # Main application
        location / {
            limit_req zone=static burst=10 nodelay;
            try_files \$uri \$uri/ /index.html;

            # Additional security headers for HTML
            location ~ \.html$ {
                add_header Cache-Control "no-cache, no-store, must-revalidate";
                add_header Pragma "no-cache";
                add_header Expires "0";
            }
        }

        # Error pages
        error_page 404 /404.html;
        error_page 500 502 503 504 /50x.html;

        location = /50x.html {
            root /usr/share/nginx/html;
        }
    }
}
EOF

# Create custom error pages
RUN echo '<!DOCTYPE html><html><head><title>404 Not Found</title></head><body><h1>404 Not Found</h1><p>The requested resource was not found.</p></body></html>' > /usr/share/nginx/html/404.html && \
    echo '<!DOCTYPE html><html><head><title>Server Error</title></head><body><h1>Server Error</h1><p>An internal server error occurred.</p></body></html>' > /usr/share/nginx/html/50x.html

# Create health check script
COPY --chown=nginxuser:nginxgroup <<EOF /usr/local/bin/healthcheck.sh
#!/bin/sh
curl -f http://localhost:8080/health || exit 1
EOF

RUN chmod +x /usr/local/bin/healthcheck.sh

# Switch to non-root user
USER nginxuser

# Expose port 8080 (non-privileged port)
EXPOSE 8080

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

# Security scan instructions
# RUN trivy filesystem --exit-code 1 --no-progress --severity HIGH,CRITICAL .
# RUN grype . --fail-on high
