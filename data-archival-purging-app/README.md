# Data Archival and Purging Admin Application

A comprehensive admin application for managing data archival and purging operations across transaction tables in a live database. The system provides configurable scheduling, monitoring, and metrics for data lifecycle management.

## 🏗️ Architecture

- **Frontend**: Flutter (Cross-platform mobile/web admin interface)
- **Backend**: Java Spring Boot (RESTful APIs and business logic)
- **Database**: MySQL (Live DB, Archival DB, Configuration DB)
- **Scheduling**: Spring Boot Scheduler with Quartz
- **Time Zone**: IST (Indian Standard Time)

## 🚀 Features

- ✅ Configurable archival and purge days per table
- ✅ Automated scheduling at 12:00 AM IST
- ✅ Real-time job status monitoring
- ✅ Comprehensive metrics and reporting
- ✅ Admin dashboard for configuration management
- ✅ Data integrity validation
- ✅ Rollback capabilities (planned)
- ✅ RESTful API endpoints
- ✅ Responsive Flutter admin interface

## 📋 Prerequisites

- Java 17 or higher
- MySQL 8.0 or higher
- Flutter 3.0 or higher
- Maven 3.6 or higher

## 🛠️ Installation & Setup

### 1. Database Setup

#### Create Live Database
```bash
mysql -u root -p < database-scripts/01_create_live_database.sql
```

#### Create Archival Database
```bash
mysql -u root -p < database-scripts/02_create_archival_database.sql
```

### 2. Backend Setup

#### Navigate to Backend Directory
```bash
cd data-archival-backend
```

#### Update Database Configuration
Edit `src/main/resources/application.yml`:
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/data_archival_live?useSSL=false&serverTimezone=IST&allowPublicKeyRetrieval=true
    username: your_username
    password: your_password

archival:
  datasource:
    url: jdbc:mysql://localhost:3306/data_archival_archive?useSSL=false&serverTimezone=IST&allowPublicKeyRetrieval=true
    username: your_username
    password: your_password
```

#### Build and Run
```bash
mvn clean install
mvn spring-boot:run
```

The backend will be available at `http://localhost:8080`

### 3. Frontend Setup

#### Navigate to Flutter App Directory
```bash
cd flutter-admin-app
```

#### Install Dependencies
```bash
flutter pub get
```

#### Update API Base URL
Edit `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://your-backend-url:8080/api';
```

#### Run the Application
```bash
# For Web
flutter run -d chrome

# For Mobile
flutter run

# For Desktop
flutter run -d windows
```

## 📚 API Documentation

### Configuration Management APIs

#### Get All Table Configurations
```http
GET /api/v1/config/tables
```

#### Create Table Configuration
```http
POST /api/v1/config/tables
Content-Type: application/json

{
  "tableName": "sample_transactions",
  "archivalDays": 30,
  "purgeDays": 365,
  "isActive": true
}
```

#### Update Table Configuration
```http
PUT /api/v1/config/tables/{id}
Content-Type: application/json

{
  "tableName": "sample_transactions",
  "archivalDays": 45,
  "purgeDays": 400,
  "isActive": true
}
```

#### Delete Table Configuration
```http
DELETE /api/v1/config/tables/{id}
```

### Job Management APIs

#### Get Job Status
```http
GET /api/v1/jobs/status
```

#### Get Job History
```http
GET /api/v1/jobs/history?tableName={name}&page=0&size=10
```

#### Get Job Statistics
```http
GET /api/v1/jobs/stats
```

### Data Management APIs

#### Trigger Archival Job
```http
POST /api/v1/data/trigger/archive?tableName={tableName}
```

#### Trigger Purge Job
```http
POST /api/v1/data/trigger/purge?tableName={tableName}
```

#### Preview Archival Data
```http
GET /api/v1/data/preview/archive?tableName={tableName}&days={days}
```

#### Preview Purge Data
```http
GET /api/v1/data/preview/purge?tableName={tableName}&days={days}
```

## 🎯 Usage Guide

### 1. Configure Tables

1. Open the Flutter admin application
2. Navigate to "Table Configuration"
3. Click "Add Configuration"
4. Enter table name, archival days, and purge days
5. Save the configuration

### 2. Monitor Jobs

1. Navigate to "Job Monitoring"
2. View running jobs and their status
3. Check job history for completed/failed jobs
4. View detailed error messages for failed jobs

### 3. View Metrics

1. Navigate to "Metrics & Analytics"
2. View system overview and data processing metrics
3. Analyze job status distribution
4. Monitor data processing volumes

### 4. Manual Job Execution

1. Navigate to "Job Monitoring"
2. Use the trigger buttons to manually start archival or purge jobs
3. Monitor job progress in real-time

## 🔧 Configuration

### Scheduler Configuration

The scheduler runs automatically at 12:00 AM IST. To modify the schedule, update the cron expression in `application.yml`:

```yaml
scheduler:
  cron:
    archival: "0 0 0 * * ?"  # 12:00 AM IST daily
```

### Database Configuration

Configure both live and archival databases in `application.yml`:

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/data_archival_live
    username: your_username
    password: your_password

archival:
  datasource:
    url: jdbc:mysql://localhost:3306/data_archival_archive
    username: your_username
    password: your_password
```

## 📊 Monitoring & Logs

### Application Logs
- Location: `logs/data-archival.log`
- Level: DEBUG (configurable)
- Rotation: Daily

### Health Checks
- Health endpoint: `http://localhost:8080/api/actuator/health`
- Metrics endpoint: `http://localhost:8080/api/actuator/metrics`

### Database Monitoring
- Monitor job execution history table
- Check system metrics table
- Review error messages in job execution history

## 🚨 Troubleshooting

### Common Issues

#### 1. Database Connection Issues
- Verify MySQL is running
- Check database credentials
- Ensure databases exist

#### 2. Scheduler Not Running
- Check application logs
- Verify timezone configuration
- Ensure Quartz tables are created

#### 3. Flutter App Not Connecting
- Verify backend is running
- Check API base URL configuration
- Ensure CORS is enabled

#### 4. Job Failures
- Check error messages in job execution history
- Verify table permissions
- Ensure archival database is accessible

### Log Analysis

```bash
# View application logs
tail -f logs/data-archival.log

# Search for errors
grep -i error logs/data-archival.log

# Search for job executions
grep -i "job execution" logs/data-archival.log
```

## 🔒 Security Considerations

- JWT-based authentication (implemented)
- Role-based access control (planned)
- API rate limiting (planned)
- Input validation and sanitization
- Database encryption at rest (recommended)
- Secure API communication (HTTPS recommended)

## 📈 Performance Optimization

- Database connection pooling
- Batch processing for large datasets
- Configurable batch sizes
- Index optimization
- Query optimization

## 🚀 Deployment

### Production Deployment

1. **Database Setup**
   - Set up MySQL cluster
   - Configure replication
   - Set up monitoring

2. **Backend Deployment**
   - Build JAR file: `mvn clean package`
   - Deploy to application server
   - Configure load balancer
   - Set up monitoring

3. **Frontend Deployment**
   - Build for production: `flutter build web`
   - Deploy to web server
   - Configure CDN (optional)

### Docker Deployment (Optional)

```dockerfile
# Backend Dockerfile
FROM openjdk:17-jdk-slim
COPY target/data-archival-purging-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review the API documentation

## 🔮 Future Enhancements

- Machine learning-based retention policies
- Automated data classification
- Cross-database archival
- Cloud storage integration
- Microservices architecture
- Message queue integration
- Distributed processing
- Auto-scaling capabilities

## 📋 Changelog

### Version 1.0.0
- Initial release
- Basic archival and purging functionality
- Flutter admin interface
- RESTful API endpoints
- Automated scheduling
- Metrics and monitoring

---

**Note**: This application is designed for production use with proper security measures and monitoring in place. Always test in a development environment before deploying to production.