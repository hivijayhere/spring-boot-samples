# Branch Role Rotation System - Deployment Guide

This guide provides step-by-step instructions for deploying the Branch Role Rotation Management System, which consists of a Spring Boot backend with MySQL database and a Flutter mobile application.

## System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │◄──►│  Spring Boot    │◄──►│   MySQL DB      │
│   (Frontend)    │    │   (Backend)     │    │   (Database)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Prerequisites

### System Requirements
- **Java**: JDK 17 or higher
- **MySQL**: Version 8.0 or higher
- **Maven**: Version 3.6 or higher
- **Flutter**: SDK 3.0 or higher
- **Operating System**: Windows, macOS, or Linux

### Development Tools
- **IDE**: IntelliJ IDEA, Eclipse, or VS Code
- **Database Client**: MySQL Workbench or similar
- **Mobile Device**: Android/iOS device or emulator

## Backend Deployment

### 1. Database Setup

#### Create MySQL Database
```sql
-- Connect to MySQL as root user
mysql -u root -p

-- Create database
CREATE DATABASE branch_role_rotation;
USE branch_role_rotation;
```

#### Run Database Schema
```bash
# Navigate to backend directory
cd /workspace/branch-role-rotation-backend

# Execute schema script
mysql -u root -p branch_role_rotation < src/main/resources/schema.sql
```

#### Verify Database Setup
```sql
-- Check tables
SHOW TABLES;

-- Verify sample data
SELECT * FROM users;
SELECT * FROM job_roles;
SELECT * FROM job_role_rotations;
```

### 2. Backend Configuration

#### Update Application Properties
Edit `src/main/resources/application.yml`:

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/branch_role_rotation?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
    username: your_mysql_username
    password: your_mysql_password
```

#### Configure JWT Secret
Update the JWT secret in `application.yml`:
```yaml
spring:
  security:
    jwt:
      secret: your_secure_jwt_secret_key_here
      expiration: 86400000 # 24 hours
```

### 3. Build and Run Backend

#### Build Application
```bash
cd /workspace/branch-role-rotation-backend
mvn clean compile
mvn package
```

#### Run Application
```bash
# Option 1: Using Maven
mvn spring-boot:run

# Option 2: Using JAR file
java -jar target/branch-role-rotation-backend-0.0.1-SNAPSHOT.jar
```

#### Verify Backend is Running
```bash
# Test health endpoint
curl http://localhost:8080/api/auth/login

# Expected response: Method not allowed (405) - this confirms server is running
```

### 4. Backend Testing

#### Test Authentication
```bash
# Test login endpoint
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"bm001","password":"password"}'
```

#### Test Job Role Endpoints
```bash
# Get token from login response, then test protected endpoint
curl -X GET http://localhost:8080/api/job-role-rotation/my-history \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Frontend Deployment

### 1. Flutter Setup

#### Install Flutter Dependencies
```bash
cd /workspace/branch-role-rotation-flutter
flutter pub get
```

#### Update API Configuration
Edit `lib/utils/app_constants.dart`:
```dart
// Update base URL if backend is not running on localhost
static const String baseUrl = 'http://YOUR_BACKEND_IP:8080/api';
```

### 2. Run Flutter Application

#### For Android
```bash
# Check connected devices
flutter devices

# Run on Android device/emulator
flutter run
```

#### For iOS (macOS only)
```bash
# Run on iOS simulator
flutter run -d ios
```

#### For Web
```bash
# Enable web support
flutter config --enable-web

# Run on web
flutter run -d web-server --web-port 3000
```

### 3. Flutter Testing

#### Test Authentication Flow
1. Launch the app
2. Use demo credentials:
   - **BM**: `bm001` / `password`
   - **BDO**: `bdo001` / `password`
   - **CSE**: `cse001` / `password`
3. Verify login success and navigation to home screen

#### Test Role-Based Views
1. **BM User**: Should see all three tabs (My Role, Team, Branch)
2. **BDO/CSE User**: Should see personal role information
3. Test "As on Date" functionality
4. Test data refresh functionality

## Production Deployment

### 1. Backend Production Setup

#### Environment Configuration
Create `application-prod.yml`:
```yaml
spring:
  datasource:
    url: jdbc:mysql://prod-db-host:3306/branch_role_rotation
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false

logging:
  level:
    com.branch.rotation: INFO
    org.springframework.security: WARN
```

#### Build Production JAR
```bash
mvn clean package -Pprod
```

#### Deploy to Server
```bash
# Copy JAR to production server
scp target/branch-role-rotation-backend-0.0.1-SNAPSHOT.jar user@prod-server:/app/

# Run on production server
java -jar -Dspring.profiles.active=prod /app/branch-role-rotation-backend-0.0.1-SNAPSHOT.jar
```

### 2. Frontend Production Build

#### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### iOS IPA (macOS only)
```bash
flutter build ios --release
# Follow Xcode instructions for App Store deployment
```

#### Web Build
```bash
flutter build web --release
# Output: build/web/
```

### 3. Database Production Setup

#### Production Database Configuration
```sql
-- Create production database
CREATE DATABASE branch_role_rotation_prod;

-- Create production user
CREATE USER 'branch_app'@'%' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON branch_role_rotation_prod.* TO 'branch_app'@'%';
FLUSH PRIVILEGES;
```

#### Run Production Schema
```bash
mysql -u branch_app -p branch_role_rotation_prod < src/main/resources/schema.sql
```

## Security Considerations

### 1. Database Security
- Use strong passwords for database users
- Enable SSL connections in production
- Regular database backups
- Access control and user permissions

### 2. Application Security
- Use strong JWT secrets (minimum 256 bits)
- Enable HTTPS in production
- Implement rate limiting
- Regular security updates

### 3. Mobile App Security
- Certificate pinning for API calls
- Secure token storage
- Code obfuscation for production builds
- Regular security audits

## Monitoring and Maintenance

### 1. Application Monitoring
- Set up application logs
- Monitor API response times
- Track user authentication failures
- Database performance monitoring

### 2. Regular Maintenance
- Database backup and recovery procedures
- Application updates and patches
- Security vulnerability assessments
- Performance optimization

## Troubleshooting

### Common Issues

#### Backend Issues
1. **Database Connection Failed**
   - Check MySQL service status
   - Verify connection credentials
   - Ensure database exists

2. **JWT Token Issues**
   - Verify JWT secret configuration
   - Check token expiration settings
   - Validate token format

#### Frontend Issues
1. **API Connection Failed**
   - Verify backend is running
   - Check network connectivity
   - Update API base URL

2. **Authentication Issues**
   - Clear app data/cache
   - Verify credentials
   - Check token storage

### Log Analysis
- Backend logs: Check application logs for errors
- Database logs: Monitor MySQL error logs
- Mobile logs: Use Flutter debugging tools

## Support and Documentation

### API Documentation
- Swagger UI available at: `http://localhost:8080/swagger-ui.html`
- API endpoints documented in controller classes

### Code Documentation
- JavaDoc comments in backend code
- Dart documentation in Flutter code
- README files in each module

### Contact Information
For technical support or questions about the Branch Role Rotation system, please refer to the project documentation or contact the development team.

## Conclusion

The Branch Role Rotation Management System is now ready for deployment. Follow this guide step-by-step to ensure a successful deployment in both development and production environments.

Remember to:
- Test thoroughly in development before production deployment
- Maintain regular backups of the database
- Monitor system performance and security
- Keep all components updated with latest security patches