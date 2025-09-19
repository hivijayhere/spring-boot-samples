# Deployment Guide - Data Archival and Purging Admin Application

This guide provides detailed instructions for deploying the Data Archival and Purging Admin Application in various environments.

## 📋 Prerequisites

### System Requirements
- **CPU**: 2+ cores
- **RAM**: 4GB+ (8GB recommended for production)
- **Storage**: 20GB+ free space
- **OS**: Linux (Ubuntu 20.04+), Windows 10+, or macOS 10.15+

### Software Requirements
- **Java**: 17 or higher
- **MySQL**: 8.0 or higher
- **Maven**: 3.6 or higher
- **Flutter**: 3.0 or higher (for frontend development)
- **Git**: Latest version

## 🗄️ Database Setup

### 1. MySQL Installation

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install mysql-server
sudo mysql_secure_installation
```

#### CentOS/RHEL
```bash
sudo yum install mysql-server
sudo systemctl start mysqld
sudo systemctl enable mysqld
sudo mysql_secure_installation
```

#### Windows
1. Download MySQL Installer from [mysql.com](https://dev.mysql.com/downloads/installer/)
2. Run the installer and follow the setup wizard
3. Configure root password and create a new user

### 2. Database Creation

```bash
# Connect to MySQL
mysql -u root -p

# Create databases
CREATE DATABASE data_archival_live;
CREATE DATABASE data_archival_archive;

# Create user for the application
CREATE USER 'archival_user'@'localhost' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON data_archival_live.* TO 'archival_user'@'localhost';
GRANT ALL PRIVILEGES ON data_archival_archive.* TO 'archival_user'@'localhost';
FLUSH PRIVILEGES;
```

### 3. Schema Setup

```bash
# Run the database scripts
mysql -u root -p data_archival_live < database-scripts/01_create_live_database.sql
mysql -u root -p data_archival_archive < database-scripts/02_create_archival_database.sql
```

## 🚀 Backend Deployment

### 1. Development Environment

#### Clone Repository
```bash
git clone <repository-url>
cd data-archival-backend
```

#### Configure Application
Edit `src/main/resources/application.yml`:
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/data_archival_live?useSSL=false&serverTimezone=IST&allowPublicKeyRetrieval=true
    username: archival_user
    password: secure_password

archival:
  datasource:
    url: jdbc:mysql://localhost:3306/data_archival_archive?useSSL=false&serverTimezone=IST&allowPublicKeyRetrieval=true
    username: archival_user
    password: secure_password
```

#### Build and Run
```bash
mvn clean install
mvn spring-boot:run
```

### 2. Production Environment

#### Build JAR File
```bash
mvn clean package -DskipTests
```

#### Create Application Directory
```bash
sudo mkdir -p /opt/data-archival
sudo cp target/data-archival-purging-1.0.0.jar /opt/data-archival/
sudo chown -R $USER:$USER /opt/data-archival
```

#### Create Systemd Service
Create `/etc/systemd/system/data-archival.service`:
```ini
[Unit]
Description=Data Archival and Purging Application
After=mysql.service

[Service]
Type=simple
User=archival
Group=archival
WorkingDirectory=/opt/data-archival
ExecStart=/usr/bin/java -jar data-archival-purging-1.0.0.jar
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

#### Create Application User
```bash
sudo useradd -r -s /bin/false archival
sudo chown -R archival:archival /opt/data-archival
```

#### Start Service
```bash
sudo systemctl daemon-reload
sudo systemctl enable data-archival
sudo systemctl start data-archival
sudo systemctl status data-archival
```

### 3. Docker Deployment

#### Create Dockerfile
```dockerfile
FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/data-archival-purging-1.0.0.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
```

#### Build and Run
```bash
docker build -t data-archival-backend .
docker run -d \
  --name data-archival-backend \
  -p 8080:8080 \
  -e DB_USERNAME=archival_user \
  -e DB_PASSWORD=secure_password \
  -e ARCHIVAL_DB_USERNAME=archival_user \
  -e ARCHIVAL_DB_PASSWORD=secure_password \
  data-archival-backend
```

## 🎨 Frontend Deployment

### 1. Development Environment

#### Setup Flutter
```bash
# Install Flutter (if not already installed)
# Follow instructions at https://flutter.dev/docs/get-started/install

cd flutter-admin-app
flutter pub get
```

#### Configure API URL
Edit `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://localhost:8080/api';
```

#### Run Application
```bash
# For Web
flutter run -d chrome

# For Mobile
flutter run

# For Desktop
flutter run -d windows
```

### 2. Production Web Deployment

#### Build for Web
```bash
flutter build web --release
```

#### Deploy to Web Server

##### Apache Configuration
Create `/etc/apache2/sites-available/data-archival.conf`:
```apache
<VirtualHost *:80>
    ServerName your-domain.com
    DocumentRoot /var/www/data-archival
    
    <Directory /var/www/data-archival>
        AllowOverride All
        Require all granted
    </Directory>
    
    # Proxy API requests to backend
    ProxyPreserveHost On
    ProxyPass /api/ http://localhost:8080/api/
    ProxyPassReverse /api/ http://localhost:8080/api/
</VirtualHost>
```

Enable the site:
```bash
sudo a2ensite data-archival
sudo systemctl reload apache2
```

##### Nginx Configuration
Create `/etc/nginx/sites-available/data-archival`:
```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/data-archival;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://localhost:8080/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/data-archival /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 3. Mobile App Deployment

#### Android
```bash
flutter build apk --release
# APK will be in build/app/outputs/flutter-apk/
```

#### iOS
```bash
flutter build ios --release
# Follow Xcode deployment process
```

## 🔧 Configuration Management

### 1. Environment Variables

Create `.env` file:
```bash
# Database Configuration
DB_USERNAME=archival_user
DB_PASSWORD=secure_password
ARCHIVAL_DB_USERNAME=archival_user
ARCHIVAL_DB_PASSWORD=secure_password

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key

# Application Configuration
SERVER_PORT=8080
LOG_LEVEL=INFO
```

### 2. Application Properties

Update `application.yml` for production:
```yaml
server:
  port: ${SERVER_PORT:8080}

spring:
  datasource:
    url: jdbc:mysql://${DB_HOST:localhost}:${DB_PORT:3306}/data_archival_live
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    
archival:
  datasource:
    url: jdbc:mysql://${ARCHIVAL_DB_HOST:localhost}:${ARCHIVAL_DB_PORT:3306}/data_archival_archive
    username: ${ARCHIVAL_DB_USERNAME}
    password: ${ARCHIVAL_DB_PASSWORD}

logging:
  level:
    com.dataarchival: ${LOG_LEVEL:INFO}
```

## 📊 Monitoring Setup

### 1. Application Monitoring

#### Enable Actuator Endpoints
The application includes Spring Boot Actuator for monitoring:
- Health: `http://localhost:8080/api/actuator/health`
- Metrics: `http://localhost:8080/api/actuator/metrics`
- Info: `http://localhost:8080/api/actuator/info`

#### Log Monitoring
```bash
# View logs
tail -f logs/data-archival.log

# Monitor errors
grep -i error logs/data-archival.log | tail -20

# Monitor job executions
grep -i "job execution" logs/data-archival.log | tail -20
```

### 2. Database Monitoring

#### MySQL Monitoring
```sql
-- Check database size
SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables
WHERE table_schema IN ('data_archival_live', 'data_archival_archive')
GROUP BY table_schema;

-- Check job execution status
SELECT 
    table_name,
    job_type,
    status,
    COUNT(*) as count
FROM job_execution_history
GROUP BY table_name, job_type, status;
```

### 3. System Monitoring

#### Resource Usage
```bash
# Check memory usage
free -h

# Check disk usage
df -h

# Check CPU usage
top -p $(pgrep java)
```

## 🔒 Security Configuration

### 1. Database Security

#### Secure MySQL Installation
```bash
# Run security script
sudo mysql_secure_installation

# Create application user with limited privileges
CREATE USER 'archival_user'@'localhost' IDENTIFIED BY 'strong_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON data_archival_live.* TO 'archival_user'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON data_archival_archive.* TO 'archival_user'@'localhost';
FLUSH PRIVILEGES;
```

### 2. Application Security

#### Enable HTTPS
```yaml
server:
  port: 8443
  ssl:
    enabled: true
    key-store: classpath:keystore.p12
    key-store-password: your_password
    key-store-type: PKCS12
```

#### Configure CORS
```java
@Configuration
public class SecurityConfig {
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(Arrays.asList("https://your-domain.com"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setAllowCredentials(true);
        return source;
    }
}
```

### 3. Network Security

#### Firewall Configuration
```bash
# Allow only necessary ports
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw allow 3306  # MySQL (if external access needed)
sudo ufw enable
```

## 🚨 Troubleshooting

### Common Issues

#### 1. Database Connection Issues
```bash
# Check MySQL status
sudo systemctl status mysql

# Test connection
mysql -u archival_user -p -h localhost

# Check logs
sudo tail -f /var/log/mysql/error.log
```

#### 2. Application Startup Issues
```bash
# Check application logs
tail -f logs/data-archival.log

# Check systemd service
sudo systemctl status data-archival
sudo journalctl -u data-archival -f
```

#### 3. Frontend Issues
```bash
# Check Flutter doctor
flutter doctor

# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release
```

### Performance Issues

#### 1. Database Performance
```sql
-- Check slow queries
SHOW VARIABLES LIKE 'slow_query_log';
SHOW VARIABLES LIKE 'long_query_time';

-- Optimize tables
OPTIMIZE TABLE table_config;
OPTIMIZE TABLE job_execution_history;
```

#### 2. Application Performance
```bash
# Monitor JVM memory
jstat -gc $(pgrep java) 5s

# Check thread dumps
jstack $(pgrep java) > thread_dump.txt
```

## 📈 Scaling

### 1. Horizontal Scaling

#### Load Balancer Configuration
```nginx
upstream data_archival_backend {
    server backend1:8080;
    server backend2:8080;
    server backend3:8080;
}

server {
    location /api/ {
        proxy_pass http://data_archival_backend;
    }
}
```

#### Database Clustering
- Set up MySQL Master-Slave replication
- Configure read replicas for reporting
- Implement database sharding if needed

### 2. Vertical Scaling

#### JVM Tuning
```bash
java -Xms2g -Xmx4g -XX:+UseG1GC -jar data-archival-purging-1.0.0.jar
```

#### Database Tuning
```sql
-- Increase buffer pool size
SET GLOBAL innodb_buffer_pool_size = 2G;

-- Optimize query cache
SET GLOBAL query_cache_size = 256M;
```

## 🔄 Backup and Recovery

### 1. Database Backup

#### Automated Backup Script
```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/backups"
DB_NAME="data_archival_live"
ARCHIVAL_DB_NAME="data_archival_archive"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup live database
mysqldump -u root -p $DB_NAME > $BACKUP_DIR/${DB_NAME}_${DATE}.sql

# Backup archival database
mysqldump -u root -p $ARCHIVAL_DB_NAME > $BACKUP_DIR/${ARCHIVAL_DB_NAME}_${DATE}.sql

# Compress backups
gzip $BACKUP_DIR/${DB_NAME}_${DATE}.sql
gzip $BACKUP_DIR/${ARCHIVAL_DB_NAME}_${DATE}.sql

# Keep only last 7 days of backups
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete
```

#### Schedule Backup
```bash
# Add to crontab
0 2 * * * /opt/scripts/backup.sh
```

### 2. Application Backup

#### Configuration Backup
```bash
# Backup configuration files
tar -czf config_backup_$(date +%Y%m%d).tar.gz \
    /opt/data-archival/application.yml \
    /etc/systemd/system/data-archival.service
```

## 📋 Maintenance

### 1. Regular Maintenance Tasks

#### Weekly Tasks
- Check application logs for errors
- Monitor database performance
- Review job execution history
- Update security patches

#### Monthly Tasks
- Analyze system metrics
- Optimize database tables
- Review and rotate logs
- Update documentation

#### Quarterly Tasks
- Security audit
- Performance review
- Capacity planning
- Disaster recovery testing

### 2. Log Management

#### Log Rotation
```bash
# Configure logrotate
sudo vim /etc/logrotate.d/data-archival

# Content:
/opt/data-archival/logs/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 archival archival
}
```

## 🎯 Production Checklist

- [ ] Database setup and configuration
- [ ] Application deployment
- [ ] Frontend deployment
- [ ] Security configuration
- [ ] Monitoring setup
- [ ] Backup configuration
- [ ] Load testing
- [ ] Documentation review
- [ ] Team training
- [ ] Go-live plan

---

**Note**: This deployment guide provides a comprehensive overview. Always test in a development environment before deploying to production. Consider your specific requirements and adjust configurations accordingly.