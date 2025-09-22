# Laravel Voice Assistant - Deployment Guide

## Overview

This guide covers various deployment strategies for the Laravel Voice Assistant application, from development to production environments.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Local Development](#local-development)
4. [Staging Deployment](#staging-deployment)
5. [Production Deployment](#production-deployment)
6. [Docker Deployment](#docker-deployment)
7. [Kubernetes Deployment](#kubernetes-deployment)
8. [Cloud Deployment](#cloud-deployment)
9. [Monitoring & Maintenance](#monitoring--maintenance)
10. [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements
- **Server**: Linux (Ubuntu 22.04+ recommended)
- **PHP**: 8.3 or higher
- **Web Server**: Nginx 1.20+ or Apache 2.4+
- **Database**: MySQL 8.0+ or PostgreSQL 13+
- **Cache**: Redis 6.0+ (recommended)
- **Memory**: 4GB RAM minimum (8GB+ recommended)
- **Storage**: 20GB minimum (SSD recommended)

### Domain & SSL
- Registered domain name
- SSL certificate (Let's Encrypt recommended)
- DNS configuration

### API Keys Required
- Google Cloud Platform (Calendar, Gmail, YouTube APIs)
- Amazon Developer (Music API)
- OpenAI API key
- Any additional service integrations

## Environment Setup

### Production Environment Variables

Create a `.env` file with production settings:

```env
# Application Settings
APP_NAME="Laravel Voice Assistant"
APP_ENV=production
APP_KEY=base64:your-generated-application-key
APP_DEBUG=false
APP_TIMEZONE=UTC
APP_URL=https://your-domain.com

# Database Configuration
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=voice_assistant_prod
DB_USERNAME=voice_assistant_user
DB_PASSWORD=secure_database_password

# Cache & Session Configuration
CACHE_STORE=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=secure_redis_password
REDIS_PORT=6379

# Security Settings
SANCTUM_STATEFUL_DOMAINS=your-domain.com
SESSION_SECURE_COOKIE=true
SESSION_SAME_SITE=strict
SESSION_LIFETIME=120

# Google Services
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_REDIRECT_URI="${APP_URL}/auth/google/callback"
YOUTUBE_API_KEY=your_youtube_api_key

# Amazon Services
AMAZON_CLIENT_ID=your_amazon_client_id
AMAZON_CLIENT_SECRET=your_amazon_client_secret
AMAZON_REDIRECT_URI="${APP_URL}/auth/amazon/callback"
AMAZON_MUSIC_API_KEY=your_amazon_music_api_key

# AI Services
OPENAI_API_KEY=your_openai_api_key
OPENAI_ORGANIZATION=your_openai_organization_id

# Mail Configuration
MAIL_MAILER=smtp
MAIL_HOST=your-smtp-server
MAIL_PORT=587
MAIL_USERNAME=your-email@domain.com
MAIL_PASSWORD=your-email-password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS="${MAIL_USERNAME}"
MAIL_FROM_NAME="${APP_NAME}"

# Logging
LOG_CHANNEL=stack
LOG_STACK=single,daily
LOG_LEVEL=info

# Monitoring (Optional)
SENTRY_LARAVEL_DSN=your_sentry_dsn
```

## Local Development

### Using Laravel Sail (Recommended)

```bash
# Install Laravel Sail
composer require laravel/sail --dev

# Publish Sail configuration
php artisan sail:install

# Start development environment
./vendor/bin/sail up -d

# Run setup inside container
./vendor/bin/sail artisan migrate
./vendor/bin/sail artisan db:seed
./vendor/bin/sail npm install
./vendor/bin/sail npm run dev
```

### Manual Local Setup

```bash
# Clone repository
git clone https://github.com/trupen1010/laravel-voice-assistant.git
cd laravel-voice-assistant

# Install dependencies
composer install
npm install

# Setup environment
cp .env.example .env
php artisan key:generate

# Setup database
php artisan migrate
php artisan db:seed

# Build assets
npm run build

# Start servers
php artisan serve &
npm run dev
```

## Staging Deployment

### Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install PHP 8.3
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install php8.3 php8.3-fpm php8.3-mysql php8.3-redis php8.3-xml php8.3-curl php8.3-mbstring php8.3-zip php8.3-bcmath php8.3-gd -y

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install nodejs -y

# Install Nginx
sudo apt install nginx -y

# Install MySQL
sudo apt install mysql-server -y

# Install Redis
sudo apt install redis-server -y
```

### Application Deployment

```bash
# Create application directory
sudo mkdir -p /var/www/voice-assistant
sudo chown -R $USER:www-data /var/www/voice-assistant

# Clone application
cd /var/www/voice-assistant
git clone https://github.com/trupen1010/laravel-voice-assistant.git .

# Install dependencies
composer install --no-dev --optimize-autoloader
npm ci --production
npm run build

# Setup permissions
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache

# Setup environment
cp .env.example .env
# Edit .env with production values
php artisan key:generate

# Setup database
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### Nginx Configuration

```nginx
# /etc/nginx/sites-available/voice-assistant
server {
    listen 80;
    server_name staging.your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name staging.your-domain.com;
    root /var/www/voice-assistant/public;
    index index.php index.html index.htm;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/staging.your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/staging.your-domain.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Gzip Compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    # WebSocket support for MCP
    location /mcp {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/voice-assistant /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## Production Deployment

### Automated Deployment Script

```bash
#!/bin/bash
# deploy.sh - Production deployment script

set -e

APP_PATH="/var/www/voice-assistant"
BACKUP_PATH="/var/backups/voice-assistant"
GIT_REPO="https://github.com/trupen1010/laravel-voice-assistant.git"

echo "🚀 Starting Laravel Voice Assistant deployment..."

# Create backup
echo "📦 Creating backup..."
sudo mkdir -p $BACKUP_PATH
sudo cp -r $APP_PATH $BACKUP_PATH/$(date +%Y%m%d_%H%M%S)

# Pull latest code
echo "📥 Pulling latest code..."
cd $APP_PATH
git fetch origin
git reset --hard origin/main

# Install/update dependencies
echo "📦 Installing dependencies..."
composer install --no-dev --optimize-autoloader --no-interaction
npm ci --production
npm run build

# Clear caches
echo "🗑️  Clearing caches..."
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear

# Run database migrations
echo "🗄️  Running migrations..."
php artisan migrate --force

# Optimize application
echo "⚡ Optimizing application..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set permissions
echo "🔐 Setting permissions..."
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache

# Restart services
echo "🔄 Restarting services..."
sudo systemctl reload nginx
sudo systemctl restart php8.3-fpm

# Restart queue workers
echo "👷 Restarting queue workers..."
php artisan queue:restart

echo "✅ Deployment completed successfully!"
echo "🌐 Application URL: https://your-domain.com"
```

### Supervisor Configuration for Queue Workers

```ini
# /etc/supervisor/conf.d/voice-assistant-worker.conf
[program:voice-assistant-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/voice-assistant/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=4
redirect_stderr=true
stdout_logfile=/var/www/voice-assistant/storage/logs/worker.log
stopwaitsecs=3600
```

```bash
# Start supervisor
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start voice-assistant-worker:*
```

## Docker Deployment

### Dockerfile

```dockerfile
# Multi-stage Dockerfile
FROM php:8.3-fpm as base

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libicu-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl

# Install Redis extension
RUN pecl install redis && docker-php-ext-enable redis

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Set working directory
WORKDIR /var/www

# Dependencies stage
FROM base as dependencies
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader

COPY package.json package-lock.json ./
RUN npm ci --production

# Assets stage
FROM dependencies as assets
COPY . .
RUN composer dump-autoload --optimize && \
    npm run build

# Production stage
FROM base as production

# Copy application files
COPY --from=assets /var/www /var/www

# Set permissions
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache && \
    chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:9000/health || exit 1

EXPOSE 9000

CMD ["php-fpm"]
```

### Docker Compose

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  app:
    build:
      context: .
      target: production
    image: voice-assistant:latest
    container_name: voice-assistant-app
    restart: unless-stopped
    working_dir: /var/www
    volumes:
      - ./storage:/var/www/storage
      - ./bootstrap/cache:/var/www/bootstrap/cache
    environment:
      - APP_ENV=production
      - DB_HOST=mysql
      - REDIS_HOST=redis
    networks:
      - voice-assistant
    depends_on:
      - mysql
      - redis

  nginx:
    image: nginx:alpine
    container_name: voice-assistant-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - .:/var/www
      - ./docker/nginx:/etc/nginx/conf.d
      - ./docker/ssl:/etc/ssl/certs
    networks:
      - voice-assistant
    depends_on:
      - app

  mysql:
    image: mysql:8.0
    container_name: voice-assistant-mysql
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: voice_assistant
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_USER: ${DB_USERNAME}
      MYSQL_PASSWORD: ${DB_PASSWORD}
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - voice-assistant

  redis:
    image: redis:7-alpine
    container_name: voice-assistant-redis
    restart: unless-stopped
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    networks:
      - voice-assistant

  queue:
    build:
      context: .
      target: production
    container_name: voice-assistant-queue
    restart: unless-stopped
    working_dir: /var/www
    command: php artisan queue:work redis --sleep=3 --tries=3
    volumes:
      - ./storage:/var/www/storage
    environment:
      - APP_ENV=production
      - DB_HOST=mysql
      - REDIS_HOST=redis
    networks:
      - voice-assistant
    depends_on:
      - mysql
      - redis

volumes:
  mysql_data:
  redis_data:

networks:
  voice-assistant:
    driver: bridge
```

### Docker Deployment Commands

```bash
# Build and start containers
docker-compose -f docker-compose.prod.yml up -d --build

# Run migrations
docker-compose -f docker-compose.prod.yml exec app php artisan migrate --force

# Generate application key
docker-compose -f docker-compose.prod.yml exec app php artisan key:generate

# Cache configuration
docker-compose -f docker-compose.prod.yml exec app php artisan config:cache

# View logs
docker-compose -f docker-compose.prod.yml logs -f app

# Scale queue workers
docker-compose -f docker-compose.prod.yml up -d --scale queue=4
```

## Kubernetes Deployment

### Kubernetes Manifests

```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: voice-assistant

---
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: voice-assistant-config
  namespace: voice-assistant
data:
  APP_ENV: "production"
  DB_CONNECTION: "mysql"
  CACHE_DRIVER: "redis"
  SESSION_DRIVER: "redis"
  QUEUE_CONNECTION: "redis"

---
# k8s/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: voice-assistant-secrets
  namespace: voice-assistant
type: Opaque
data:
  APP_KEY: base64-encoded-app-key
  DB_PASSWORD: base64-encoded-db-password
  REDIS_PASSWORD: base64-encoded-redis-password
  GOOGLE_CLIENT_SECRET: base64-encoded-google-secret
  AMAZON_CLIENT_SECRET: base64-encoded-amazon-secret
  OPENAI_API_KEY: base64-encoded-openai-key

---
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: voice-assistant-app
  namespace: voice-assistant
spec:
  replicas: 3
  selector:
    matchLabels:
      app: voice-assistant-app
  template:
    metadata:
      labels:
        app: voice-assistant-app
    spec:
      containers:
      - name: app
        image: voice-assistant:latest
        ports:
        - containerPort: 9000
        envFrom:
        - configMapRef:
            name: voice-assistant-config
        - secretRef:
            name: voice-assistant-secrets
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 9000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 9000
          initialDelaySeconds: 5
          periodSeconds: 5

---
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: voice-assistant-service
  namespace: voice-assistant
spec:
  selector:
    app: voice-assistant-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9000
  type: ClusterIP

---
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: voice-assistant-ingress
  namespace: voice-assistant
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - your-domain.com
    secretName: voice-assistant-tls
  rules:
  - host: your-domain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: voice-assistant-service
            port:
              number: 80
```

```bash
# Deploy to Kubernetes
kubectl apply -f k8s/

# Check deployment status
kubectl get pods -n voice-assistant

# View logs
kubectl logs -f deployment/voice-assistant-app -n voice-assistant

# Scale deployment
kubectl scale deployment voice-assistant-app --replicas=5 -n voice-assistant
```

## Cloud Deployment

### AWS Deployment (using Elastic Beanstalk)

```bash
# Install EB CLI
pip install awsebcli

# Initialize Elastic Beanstalk
eb init voice-assistant --platform "PHP 8.3" --region us-east-1

# Create environment
eb create production --database.engine mysql --database.username voiceassistant

# Deploy application
eb deploy

# Set environment variables
eb setenv APP_KEY="your-app-key" \
         DB_HOST="your-rds-endpoint" \
         REDIS_HOST="your-elasticache-endpoint" \
         GOOGLE_CLIENT_ID="your-google-client-id"

# Open application
eb open
```

### Google Cloud Deployment (using Cloud Run)

```bash
# Build and push container
gcloud builds submit --tag gcr.io/your-project/voice-assistant

# Deploy to Cloud Run
gcloud run deploy voice-assistant \
  --image gcr.io/your-project/voice-assistant \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --memory 512Mi \
  --cpu 1 \
  --max-instances 100

# Set environment variables
gcloud run services update voice-assistant \
  --set-env-vars="APP_KEY=your-app-key,DB_HOST=your-db-host"
```

### Azure Deployment (using Container Instances)

```bash
# Create resource group
az group create --name voice-assistant-rg --location eastus

# Create container registry
az acr create --resource-group voice-assistant-rg --name voiceassistantacr --sku Basic

# Build and push image
az acr build --registry voiceassistantacr --image voice-assistant:latest .

# Deploy container
az container create \
  --resource-group voice-assistant-rg \
  --name voice-assistant \
  --image voiceassistantacr.azurecr.io/voice-assistant:latest \
  --cpu 1 \
  --memory 2 \
  --ports 80
```

## Monitoring & Maintenance

### Health Check Endpoints

```php
// routes/web.php
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now(),
        'services' => [
            'database' => DB::connection()->getPdo() ? 'connected' : 'disconnected',
            'redis' => Redis::connection()->ping() ? 'connected' : 'disconnected',
            'queue' => Queue::size() < 1000 ? 'healthy' : 'overloaded'
        ]
    ]);
});

Route::get('/health/deep', function () {
    // More comprehensive health checks
    $checks = [
        'google_api' => checkGoogleApiHealth(),
        'amazon_api' => checkAmazonApiHealth(),
        'openai_api' => checkOpenAIApiHealth(),
        'storage' => checkStorageHealth(),
        'voice_processing' => checkVoiceProcessingHealth()
    ];
    
    $allHealthy = collect($checks)->every(fn($status) => $status === 'healthy');
    
    return response()->json([
        'status' => $allHealthy ? 'healthy' : 'degraded',
        'checks' => $checks,
        'timestamp' => now()
    ], $allHealthy ? 200 : 503);
});
```

### Monitoring Setup

```bash
# Install monitoring tools
composer require sentry/sentry-laravel
composer require pusher/pusher-php-server

# Publish Sentry config
php artisan vendor:publish --provider="Sentry\Laravel\ServiceProvider"

# Setup log monitoring
php artisan make:command MonitorLogs
```

### Backup Scripts

```bash
#!/bin/bash
# backup.sh - Automated backup script

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/voice-assistant"
APP_DIR="/var/www/voice-assistant"
DB_NAME="voice_assistant_prod"

# Create backup directory
mkdir -p $BACKUP_DIR/$DATE

# Backup database
mysqldump -u root -p$MYSQL_ROOT_PASSWORD $DB_NAME > $BACKUP_DIR/$DATE/database.sql

# Backup application files
tar -czf $BACKUP_DIR/$DATE/application.tar.gz -C $APP_DIR . --exclude=node_modules --exclude=vendor

# Backup storage directory
tar -czf $BACKUP_DIR/$DATE/storage.tar.gz -C $APP_DIR/storage .

# Upload to cloud storage (optional)
# aws s3 cp $BACKUP_DIR/$DATE/ s3://your-backup-bucket/$DATE/ --recursive

# Clean old backups (keep last 30 days)
find $BACKUP_DIR -type d -mtime +30 -exec rm -rf {} +

echo "Backup completed: $BACKUP_DIR/$DATE"
```

### Performance Monitoring

```bash
# Setup performance monitoring with New Relic
composer require newrelic/monolog-enricher

# Or use Laravel Telescope
composer require laravel/telescope
php artisan telescope:install
php artisan migrate
```

## Troubleshooting

### Common Issues

#### 1. Voice Recognition Not Working
```bash
# Check browser permissions
# Ensure HTTPS is enabled
# Verify microphone access

# Debug voice processing
php artisan tinker
>>> App\Services\VoiceProcessingService::test();
```

#### 2. MCP Tools Failing
```bash
# Test MCP connection
php artisan mcp:inspector voice-assistant

# Check tool registration
php artisan route:list --name=mcp

# Verify service tokens
php artisan tinker
>>> User::find(1)->serviceTokens;
```

#### 3. Queue Workers Not Processing
```bash
# Check queue status
php artisan queue:monitor

# Restart workers
php artisan queue:restart

# Check supervisor logs
sudo tail -f /var/log/supervisor/supervisord.log
```

#### 4. Database Connection Issues
```bash
# Test database connection
php artisan tinker
>>> DB::connection()->getPdo();

# Check database logs
sudo tail -f /var/log/mysql/error.log

# Verify credentials
mysql -u voice_assistant_user -p voice_assistant_prod
```

#### 5. SSL Certificate Issues
```bash
# Renew Let's Encrypt certificate
sudo certbot renew

# Check certificate status
sudo certbot certificates

# Test SSL configuration
ssl-cert-check -c /etc/letsencrypt/live/your-domain.com/cert.pem
```

### Log Locations

```bash
# Application logs
tail -f /var/www/voice-assistant/storage/logs/laravel.log

# Nginx logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log

# PHP-FPM logs
tail -f /var/log/php8.3-fpm.log

# Queue worker logs
tail -f /var/www/voice-assistant/storage/logs/worker.log

# MySQL logs
tail -f /var/log/mysql/error.log

# Redis logs
tail -f /var/log/redis/redis-server.log
```

### Emergency Recovery

```bash
#!/bin/bash
# emergency-recovery.sh - Quick recovery script

echo "🚨 Starting emergency recovery..."

# Stop application
sudo systemctl stop nginx
sudo systemctl stop php8.3-fpm

# Restore from backup
echo "📦 Restoring from latest backup..."
LATEST_BACKUP=$(ls -t /var/backups/voice-assistant/ | head -1)
cd /var/www/voice-assistant
tar -xzf /var/backups/voice-assistant/$LATEST_BACKUP/application.tar.gz
tar -xzf /var/backups/voice-assistant/$LATEST_BACKUP/storage.tar.gz -C storage/

# Restore database
echo "🗄️  Restoring database..."
mysql -u root -p voice_assistant_prod < /var/backups/voice-assistant/$LATEST_BACKUP/database.sql

# Clear caches
echo "🗑️  Clearing caches..."
php artisan cache:clear
php artisan config:clear
php artisan view:clear

# Restart services
echo "🔄 Restarting services..."
sudo systemctl start php8.3-fpm
sudo systemctl start nginx
sudo supervisorctl restart all

echo "✅ Emergency recovery completed!"
```

---

**Deployment Version**: 1.0  
**Last Updated**: September 22, 2025  
**Status**: Production Ready

For additional support, consult the [troubleshooting guide](TROUBLESHOOTING.md) or create an issue on GitHub.