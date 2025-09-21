# API Specifications for Data Archival System

## Base URL
```
https://api.company.com/archival/v1
```

## Authentication
All API endpoints require authentication using JWT tokens in the Authorization header:
```
Authorization: Bearer <jwt_token>
```

## API Endpoints

### 1. Job Management APIs

#### Get All Jobs
```http
GET /jobs
Query Parameters:
- page: int (default: 1)
- limit: int (default: 20)
- status: string (pending|running|completed|failed|cancelled)
- table_name: string
- date_from: string (YYYY-MM-DD)
- date_to: string (YYYY-MM-DD)

Response:
{
  "data": [
    {
      "id": 1,
      "job_name": "daily_transaction_archive",
      "table_name": "transactions",
      "status": "completed",
      "policy_id": 1,
      "started_at": "2024-01-15T02:00:00Z",
      "completed_at": "2024-01-15T02:15:30Z",
      "records_processed": 50000,
      "records_archived": 45000,
      "error_message": null,
      "created_at": "2024-01-15T01:55:00Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 10,
    "total_records": 200,
    "per_page": 20
  }
}
```

#### Get Job Details
```http
GET /jobs/{job_id}

Response:
{
  "data": {
    "id": 1,
    "job_name": "daily_transaction_archive",
    "table_name": "transactions",
    "status": "running",
    "policy": {
      "id": 1,
      "retention_days": 365,
      "archival_method": "soft_delete"
    },
    "progress": {
      "percentage": 75,
      "records_processed": 37500,
      "records_archived": 30000,
      "estimated_completion": "2024-01-15T02:20:00Z"
    },
    "logs": [
      {
        "id": 1,
        "log_level": "INFO",
        "message": "Job started successfully",
        "created_at": "2024-01-15T02:00:00Z"
      }
    ],
    "started_at": "2024-01-15T02:00:00Z",
    "completed_at": null,
    "error_message": null,
    "created_at": "2024-01-15T01:55:00Z"
  }
}
```

#### Create Job
```http
POST /jobs
Content-Type: application/json

Request Body:
{
  "job_name": "manual_archive_job",
  "table_name": "transactions",
  "policy_id": 1,
  "execute_immediately": true
}

Response:
{
  "data": {
    "id": 123,
    "job_name": "manual_archive_job",
    "status": "pending",
    "created_at": "2024-01-15T10:30:00Z"
  },
  "message": "Job created successfully"
}
```

#### Update Job Status
```http
PATCH /jobs/{job_id}/status
Content-Type: application/json

Request Body:
{
  "status": "cancelled",
  "reason": "Manual cancellation by admin"
}

Response:
{
  "data": {
    "id": 123,
    "status": "cancelled",
    "updated_at": "2024-01-15T10:35:00Z"
  },
  "message": "Job status updated successfully"
}
```

### 2. Scheduler Management APIs

#### Get All Schedules
```http
GET /schedules

Response:
{
  "data": [
    {
      "id": 1,
      "job_name": "daily_transaction_archive",
      "cron_expression": "0 2 * * *",
      "is_active": true,
      "next_run_at": "2024-01-16T02:00:00Z",
      "last_run_at": "2024-01-15T02:00:00Z",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

#### Create Schedule
```http
POST /schedules
Content-Type: application/json

Request Body:
{
  "job_name": "weekly_cleanup",
  "cron_expression": "0 3 * * 0",
  "is_active": true
}

Response:
{
  "data": {
    "id": 2,
    "job_name": "weekly_cleanup",
    "cron_expression": "0 3 * * 0",
    "is_active": true,
    "next_run_at": "2024-01-21T03:00:00Z",
    "created_at": "2024-01-15T10:30:00Z"
  },
  "message": "Schedule created successfully"
}
```

#### Update Schedule
```http
PATCH /schedules/{schedule_id}
Content-Type: application/json

Request Body:
{
  "cron_expression": "0 1 * * *",
  "is_active": false
}

Response:
{
  "data": {
    "id": 1,
    "cron_expression": "0 1 * * *",
    "is_active": false,
    "updated_at": "2024-01-15T10:35:00Z"
  },
  "message": "Schedule updated successfully"
}
```

#### Test Cron Expression
```http
POST /schedules/test-cron
Content-Type: application/json

Request Body:
{
  "cron_expression": "0 2 * * *"
}

Response:
{
  "data": {
    "cron_expression": "0 2 * * *",
    "is_valid": true,
    "next_runs": [
      "2024-01-16T02:00:00Z",
      "2024-01-17T02:00:00Z",
      "2024-01-18T02:00:00Z"
    ],
    "description": "At 02:00 every day"
  }
}
```

### 3. Policy Management APIs

#### Get All Policies
```http
GET /policies

Response:
{
  "data": [
    {
      "id": 1,
      "table_name": "transactions",
      "retention_days": 365,
      "archival_method": "soft_delete",
      "is_active": true,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-15T10:30:00Z"
    }
  ]
}
```

#### Create Policy
```http
POST /policies
Content-Type: application/json

Request Body:
{
  "table_name": "user_sessions",
  "retention_days": 90,
  "archival_method": "hard_delete",
  "is_active": true
}

Response:
{
  "data": {
    "id": 2,
    "table_name": "user_sessions",
    "retention_days": 90,
    "archival_method": "hard_delete",
    "is_active": true,
    "created_at": "2024-01-15T10:30:00Z"
  },
  "message": "Policy created successfully"
}
```

#### Test Policy Impact
```http
POST /policies/{policy_id}/test
Content-Type: application/json

Request Body:
{
  "dry_run": true
}

Response:
{
  "data": {
    "policy_id": 1,
    "estimated_records": 150000,
    "estimated_size_mb": 2500,
    "estimated_processing_time": "00:15:30",
    "affected_tables": ["transactions", "transaction_items"],
    "test_results": {
      "records_to_archive": 150000,
      "records_to_delete": 0,
      "space_to_free_mb": 2500
    }
  }
}
```

### 4. Monitoring APIs

#### Get System Metrics
```http
GET /metrics

Response:
{
  "data": {
    "job_stats": {
      "total_jobs": 150,
      "successful_jobs": 140,
      "failed_jobs": 8,
      "running_jobs": 2,
      "success_rate": 93.33
    },
    "performance": {
      "avg_processing_time": "00:12:30",
      "total_records_processed": 5000000,
      "total_space_freed_mb": 50000
    },
    "system_health": {
      "database_connections": 5,
      "memory_usage_mb": 1024,
      "disk_space_available_gb": 500
    }
  }
}
```

#### Get Job Logs
```http
GET /jobs/{job_id}/logs
Query Parameters:
- level: string (INFO|WARN|ERROR|DEBUG)
- limit: int (default: 100)

Response:
{
  "data": [
    {
      "id": 1,
      "log_level": "INFO",
      "message": "Job started successfully",
      "created_at": "2024-01-15T02:00:00Z"
    },
    {
      "id": 2,
      "log_level": "INFO",
      "message": "Processing batch 1 of 10",
      "created_at": "2024-01-15T02:01:00Z"
    }
  ]
}
```

### 5. Error Handling

#### Standard Error Response
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid cron expression provided",
    "details": {
      "field": "cron_expression",
      "value": "invalid_cron",
      "constraint": "Must be a valid cron expression"
    },
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_123456789"
  }
}
```

#### Error Codes
- `VALIDATION_ERROR`: Input validation failed
- `NOT_FOUND`: Resource not found
- `UNAUTHORIZED`: Authentication required
- `FORBIDDEN`: Insufficient permissions
- `CONFLICT`: Resource conflict (e.g., job already running)
- `INTERNAL_ERROR`: Server internal error
- `SERVICE_UNAVAILABLE`: Service temporarily unavailable

## Rate Limiting
- **Standard Rate Limit**: 1000 requests per hour per user
- **Bulk Operations**: 100 requests per hour per user
- **Admin Operations**: 5000 requests per hour per user

## Response Headers
```
X-Rate-Limit-Limit: 1000
X-Rate-Limit-Remaining: 999
X-Rate-Limit-Reset: 1642248000
X-Request-ID: req_123456789
```