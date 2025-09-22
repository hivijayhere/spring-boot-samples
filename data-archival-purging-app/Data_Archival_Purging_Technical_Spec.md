# Data Archival and Purging Admin Application - Technical Specification

## 1. Project Overview

### 1.1 Purpose
A comprehensive admin application for managing data archival and purging operations across transaction tables in a live database. The system provides configurable scheduling, monitoring, and metrics for data lifecycle management.

### 1.2 Technology Stack
- **Frontend**: Flutter (Cross-platform mobile/web admin interface)
- **Backend**: Java Spring Boot (RESTful APIs and business logic)
- **Database**: MySQL (Live DB, Archival DB, Configuration DB)
- **Scheduling**: Spring Boot Scheduler with Quartz
- **Time Zone**: IST (Indian Standard Time)

### 1.3 Key Features
- Configurable archival and purge days per table
- Automated scheduling at 12:00 AM IST
- Real-time job status monitoring
- Comprehensive metrics and reporting
- Admin dashboard for configuration management
- Data integrity validation
- Rollback capabilities

## 2. System Architecture

### 2.1 High-Level Architecture
```
[Flutter Admin App] ↔ [Spring Boot API] ↔ [MySQL Live DB]
                           ↓
                    [MySQL Archival DB]
                           ↓
                    [Scheduler Service]
```

### 2.2 Database Design

#### 2.2.1 Configuration Tables
```sql
-- Table configuration for archival/purge settings
CREATE TABLE table_config (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(255) NOT NULL UNIQUE,
    archival_days INT NOT NULL DEFAULT 30,
    purge_days INT NOT NULL DEFAULT 365,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Job execution history
CREATE TABLE job_execution_history (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(255) NOT NULL,
    job_type ENUM('ARCHIVE', 'PURGE') NOT NULL,
    status ENUM('PENDING', 'RUNNING', 'COMPLETED', 'FAILED') NOT NULL,
    records_processed INT DEFAULT 0,
    records_archived INT DEFAULT 0,
    records_purged INT DEFAULT 0,
    start_time TIMESTAMP NULL,
    end_time TIMESTAMP NULL,
    error_message TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- System metrics
CREATE TABLE system_metrics (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(255) NOT NULL,
    total_records BIGINT DEFAULT 0,
    archived_records BIGINT DEFAULT 0,
    purged_records BIGINT DEFAULT 0,
    last_archival_date TIMESTAMP NULL,
    last_purge_date TIMESTAMP NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## 3. API Specifications

### 3.1 Configuration Management APIs

#### 3.1.1 Get All Table Configurations
```
GET /api/v1/config/tables
Response: List<TableConfigDTO>
```

#### 3.1.2 Create/Update Table Configuration
```
POST /api/v1/config/tables
PUT /api/v1/config/tables/{id}
Request: TableConfigDTO
Response: TableConfigDTO
```

#### 3.1.3 Delete Table Configuration
```
DELETE /api/v1/config/tables/{id}
Response: SuccessMessage
```

### 3.2 Job Management APIs

#### 3.2.1 Get Job Status
```
GET /api/v1/jobs/status
Response: List<JobStatusDTO>
```

#### 3.2.2 Trigger Manual Job
```
POST /api/v1/jobs/trigger
Request: JobTriggerDTO
Response: JobExecutionDTO
```

#### 3.2.3 Get Job History
```
GET /api/v1/jobs/history?tableName={name}&limit={limit}
Response: List<JobExecutionDTO>
```

### 3.3 Metrics APIs

#### 3.3.1 Get System Metrics
```
GET /api/v1/metrics/system
Response: SystemMetricsDTO
```

#### 3.3.2 Get Table Metrics
```
GET /api/v1/metrics/table/{tableName}
Response: TableMetricsDTO
```

#### 3.3.3 Get Dashboard Data
```
GET /api/v1/metrics/dashboard
Response: DashboardDTO
```

### 3.4 Data Management APIs

#### 3.4.1 Preview Data for Archival
```
GET /api/v1/data/preview/archive?tableName={name}&days={days}
Response: DataPreviewDTO
```

#### 3.4.2 Preview Data for Purge
```
GET /api/v1/data/preview/purge?tableName={name}&days={days}
Response: DataPreviewDTO
```

#### 3.4.3 Rollback Operation
```
POST /api/v1/data/rollback
Request: RollbackDTO
Response: RollbackResultDTO
```

## 4. Use Cases

### 4.1 Primary Use Cases

#### UC-1: Configure Table Archival Settings
**Actor**: Admin User
**Precondition**: Admin is logged in
**Main Flow**:
1. Admin navigates to table configuration screen
2. Admin selects a table from the list
3. Admin sets archival days (e.g., 30 days)
4. Admin sets purge days (e.g., 365 days)
5. Admin saves configuration
6. System validates and stores configuration

#### UC-2: Schedule Automatic Archival
**Actor**: System Scheduler
**Precondition**: Table configurations exist
**Main Flow**:
1. Scheduler triggers at 12:00 AM IST
2. System identifies tables due for archival
3. System creates archival jobs
4. System executes archival process
5. System updates metrics and status

#### UC-3: Monitor Job Execution
**Actor**: Admin User
**Precondition**: Jobs are running
**Main Flow**:
1. Admin opens dashboard
2. Admin views current job status
3. Admin checks execution history
4. Admin reviews metrics and reports

#### UC-4: Manual Job Trigger
**Actor**: Admin User
**Precondition**: Table configuration exists
**Main Flow**:
1. Admin selects table for manual operation
2. Admin chooses operation type (archive/purge)
3. Admin confirms operation
4. System executes job immediately
5. Admin monitors progress

### 4.2 Secondary Use Cases

#### UC-5: Data Rollback
**Actor**: Admin User
**Precondition**: Previous operation completed
**Main Flow**:
1. Admin identifies operation to rollback
2. Admin confirms rollback action
3. System restores data from archival DB
4. System updates status and metrics

#### UC-6: System Health Check
**Actor**: System
**Precondition**: System is running
**Main Flow**:
1. System performs health checks
2. System validates database connections
3. System checks scheduler status
4. System reports health status

## 5. Data Models

### 5.1 DTOs (Data Transfer Objects)

#### TableConfigDTO
```java
public class TableConfigDTO {
    private Long id;
    private String tableName;
    private Integer archivalDays;
    private Integer purgeDays;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
```

#### JobExecutionDTO
```java
public class JobExecutionDTO {
    private Long id;
    private String tableName;
    private String jobType;
    private String status;
    private Integer recordsProcessed;
    private Integer recordsArchived;
    private Integer recordsPurged;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String errorMessage;
}
```

#### SystemMetricsDTO
```java
public class SystemMetricsDTO {
    private Long totalTables;
    private Long activeJobs;
    private Long completedJobs;
    private Long failedJobs;
    private Long totalRecordsArchived;
    private Long totalRecordsPurged;
    private LocalDateTime lastExecutionTime;
}
```

## 6. Implementation Plan

### 6.1 Phase 1: Core Backend (Week 1-2)
- Spring Boot application setup
- Database schema creation
- Basic CRUD operations
- Scheduler implementation

### 6.2 Phase 2: API Development (Week 3)
- RESTful API endpoints
- Data validation
- Error handling
- Logging implementation

### 6.3 Phase 3: Flutter Frontend (Week 4-5)
- Admin dashboard UI
- Configuration screens
- Monitoring interfaces
- Responsive design

### 6.4 Phase 4: Testing & Deployment (Week 6)
- Unit testing
- Integration testing
- Performance testing
- Production deployment

## 7. Security Considerations

### 7.1 Authentication & Authorization
- JWT-based authentication
- Role-based access control
- API rate limiting
- Input validation and sanitization

### 7.2 Data Security
- Database encryption at rest
- Secure API communication (HTTPS)
- Audit logging
- Data masking for sensitive information

## 8. Performance Requirements

### 8.1 Response Times
- API responses: < 200ms
- Dashboard loading: < 2 seconds
- Job execution: Configurable batch sizes

### 8.2 Scalability
- Support for 100+ tables
- Handle 1M+ records per table
- Concurrent job execution
- Database connection pooling

## 9. Monitoring & Alerting

### 9.1 Metrics
- Job execution success/failure rates
- Data processing volumes
- System performance metrics
- Database health indicators

### 9.2 Alerts
- Job failure notifications
- System resource alerts
- Data integrity warnings
- Performance degradation alerts

## 10. Future Enhancements

### 10.1 Advanced Features
- Machine learning-based retention policies
- Automated data classification
- Cross-database archival
- Cloud storage integration

### 10.2 Scalability Improvements
- Microservices architecture
- Message queue integration
- Distributed processing
- Auto-scaling capabilities

## 11. Deployment Architecture

### 11.1 Production Environment
- Load balancer
- Application servers (2+ instances)
- Database cluster (Master-Slave)
- Monitoring and logging stack

### 11.2 Development Environment
- Local development setup
- Docker containerization
- CI/CD pipeline
- Automated testing

## 12. Maintenance & Support

### 12.1 Regular Maintenance
- Database optimization
- Log rotation
- Security updates
- Performance tuning

### 12.2 Support Procedures
- Incident response process
- Escalation procedures
- Documentation updates
- User training materials