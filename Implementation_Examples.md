# Implementation Examples for Data Archival System

## 1. Core Archival Engine Implementation

### Python Implementation

```python
import mysql.connector
from datetime import datetime, timedelta
import json
import logging
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from enum import Enum

class ArchivalMethod(Enum):
    SOFT_DELETE = "soft_delete"
    HARD_DELETE = "hard_delete"
    PARTITION_MOVE = "partition_move"

@dataclass
class ArchivalJob:
    id: int
    job_name: str
    table_name: str
    policy_id: int
    status: str
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    records_processed: int = 0
    records_archived: int = 0
    error_message: Optional[str] = None

class ArchivalEngine:
    def __init__(self, db_config: Dict):
        self.db_config = db_config
        self.logger = logging.getLogger(__name__)
        
    def get_connection(self):
        """Get database connection with retry logic"""
        max_retries = 3
        for attempt in range(max_retries):
            try:
                return mysql.connector.connect(**self.db_config)
            except mysql.connector.Error as e:
                self.logger.warning(f"Connection attempt {attempt + 1} failed: {e}")
                if attempt == max_retries - 1:
                    raise
                time.sleep(2 ** attempt)  # Exponential backoff
    
    def execute_archival_job(self, job: ArchivalJob) -> bool:
        """Execute archival job with comprehensive error handling"""
        conn = None
        try:
            conn = self.get_connection()
            cursor = conn.cursor()
            
            # Update job status to running
            self._update_job_status(cursor, job.id, "running", started_at=datetime.now())
            conn.commit()
            
            # Get archival policy
            policy = self._get_archival_policy(cursor, job.policy_id)
            if not policy:
                raise ValueError(f"Policy {job.policy_id} not found")
            
            # Execute archival based on method
            if policy['archival_method'] == ArchivalMethod.SOFT_DELETE.value:
                success = self._soft_delete_archival(cursor, job, policy)
            elif policy['archival_method'] == ArchivalMethod.HARD_DELETE.value:
                success = self._hard_delete_archival(cursor, job, policy)
            elif policy['archival_method'] == ArchivalMethod.PARTITION_MOVE.value:
                success = self._partition_move_archival(cursor, job, policy)
            else:
                raise ValueError(f"Unknown archival method: {policy['archival_method']}")
            
            if success:
                self._update_job_status(cursor, job.id, "completed", 
                                      completed_at=datetime.now(),
                                      records_processed=job.records_processed,
                                      records_archived=job.records_archived)
                conn.commit()
                self.logger.info(f"Job {job.id} completed successfully")
                return True
            else:
                raise Exception("Archival process failed")
                
        except Exception as e:
            self.logger.error(f"Job {job.id} failed: {str(e)}")
            if conn:
                try:
                    self._update_job_status(cursor, job.id, "failed", 
                                          error_message=str(e))
                    conn.commit()
                except:
                    pass
            return False
        finally:
            if conn:
                conn.close()
    
    def _soft_delete_archival(self, cursor, job: ArchivalJob, policy: Dict) -> bool:
        """Implement soft delete archival"""
        try:
            # Create archive table if it doesn't exist
            archive_table = f"archived_{job.table_name}"
            self._create_archive_table(cursor, job.table_name, archive_table)
            
            # Calculate cutoff date
            cutoff_date = datetime.now() - timedelta(days=policy['retention_days'])
            
            # Get records to archive
            select_query = f"""
                SELECT * FROM {job.table_name} 
                WHERE created_at < %s 
                AND archived_at IS NULL
                LIMIT 1000
            """
            cursor.execute(select_query, (cutoff_date,))
            records = cursor.fetchall()
            
            if not records:
                return True
            
            # Get column names
            cursor.execute(f"DESCRIBE {job.table_name}")
            columns = [row[0] for row in cursor.fetchall()]
            
            # Insert into archive table
            placeholders = ', '.join(['%s'] * len(columns))
            insert_query = f"""
                INSERT INTO {archive_table} 
                (original_id, {', '.join(columns)}, archived_at, archived_by)
                VALUES ({', '.join(['%s'] * (len(columns) + 2))})
            """
            
            for record in records:
                archive_data = list(record) + [datetime.now(), 'system']
                cursor.execute(insert_query, archive_data)
                job.records_processed += 1
                job.records_archived += 1
            
            # Mark original records as archived
            update_query = f"""
                UPDATE {job.table_name} 
                SET archived_at = %s, archived_by = %s
                WHERE id IN ({', '.join(['%s'] * len(records))})
            """
            record_ids = [record[0] for record in records]
            cursor.execute(update_query, [datetime.now(), 'system'] + record_ids)
            
            return True
            
        except Exception as e:
            self.logger.error(f"Soft delete archival failed: {e}")
            return False
    
    def _hard_delete_archival(self, cursor, job: ArchivalJob, policy: Dict) -> bool:
        """Implement hard delete archival"""
        try:
            cutoff_date = datetime.now() - timedelta(days=policy['retention_days'])
            
            # First, create backup in archive table
            archive_table = f"archived_{job.table_name}"
            self._create_archive_table(cursor, job.table_name, archive_table)
            
            # Copy records to archive before deletion
            backup_query = f"""
                INSERT INTO {archive_table} 
                (original_id, transaction_data, archived_at, archived_by)
                SELECT id, JSON_OBJECT(
                    {', '.join([f"'{col}', {col}" for col in self._get_table_columns(cursor, job.table_name)])}
                ), %s, %s
                FROM {job.table_name} 
                WHERE created_at < %s
                LIMIT 1000
            """
            cursor.execute(backup_query, (datetime.now(), 'system', cutoff_date))
            archived_count = cursor.rowcount
            
            # Delete original records
            delete_query = f"""
                DELETE FROM {job.table_name} 
                WHERE created_at < %s
                LIMIT 1000
            """
            cursor.execute(delete_query, (cutoff_date,))
            deleted_count = cursor.rowcount
            
            job.records_processed = archived_count
            job.records_archived = deleted_count
            
            return True
            
        except Exception as e:
            self.logger.error(f"Hard delete archival failed: {e}")
            return False
    
    def _partition_move_archival(self, cursor, job: ArchivalJob, policy: Dict) -> bool:
        """Implement partition-based archival"""
        try:
            # This is a simplified example - actual implementation would depend on table structure
            cutoff_date = datetime.now() - timedelta(days=policy['retention_days'])
            
            # Create archive partition
            archive_table = f"archived_{job.table_name}"
            self._create_archive_table(cursor, job.table_name, archive_table)
            
            # Move data to archive partition
            move_query = f"""
                INSERT INTO {archive_table} 
                SELECT *, %s, %s FROM {job.table_name} 
                WHERE created_at < %s
            """
            cursor.execute(move_query, (datetime.now(), 'system', cutoff_date))
            moved_count = cursor.rowcount
            
            # Remove from original table
            delete_query = f"DELETE FROM {job.table_name} WHERE created_at < %s"
            cursor.execute(delete_query, (cutoff_date,))
            
            job.records_processed = moved_count
            job.records_archived = moved_count
            
            return True
            
        except Exception as e:
            self.logger.error(f"Partition move archival failed: {e}")
            return False
    
    def _create_archive_table(self, cursor, original_table: str, archive_table: str):
        """Create archive table with proper structure"""
        create_query = f"""
            CREATE TABLE IF NOT EXISTS {archive_table} (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                original_id BIGINT NOT NULL,
                transaction_data JSON NOT NULL,
                archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                archived_by VARCHAR(100) NOT NULL,
                INDEX idx_archived_at (archived_at),
                INDEX idx_original_id (original_id)
            )
        """
        cursor.execute(create_query)
    
    def _get_table_columns(self, cursor, table_name: str) -> List[str]:
        """Get column names for a table"""
        cursor.execute(f"DESCRIBE {table_name}")
        return [row[0] for row in cursor.fetchall()]
    
    def _update_job_status(self, cursor, job_id: int, status: str, **kwargs):
        """Update job status in database"""
        update_fields = []
        values = []
        
        for field, value in kwargs.items():
            update_fields.append(f"{field} = %s")
            values.append(value)
        
        update_fields.append("status = %s")
        values.append(status)
        values.append(job_id)
        
        query = f"""
            UPDATE archival_jobs 
            SET {', '.join(update_fields)}
            WHERE id = %s
        """
        cursor.execute(query, values)
    
    def _get_archival_policy(self, cursor, policy_id: int) -> Optional[Dict]:
        """Get archival policy by ID"""
        cursor.execute("""
            SELECT id, table_name, retention_days, archival_method, is_active
            FROM archival_policies 
            WHERE id = %s AND is_active = TRUE
        """, (policy_id,))
        
        result = cursor.fetchone()
        if result:
            return {
                'id': result[0],
                'table_name': result[1],
                'retention_days': result[2],
                'archival_method': result[3],
                'is_active': result[4]
            }
        return None
```

## 2. Scheduler Service Implementation

```python
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from apscheduler.jobstores.sqlalchemy import SQLAlchemyJobStore
import atexit
import logging

class ArchivalScheduler:
    def __init__(self, db_config: Dict):
        self.db_config = db_config
        self.logger = logging.getLogger(__name__)
        
        # Configure job store
        jobstore_url = f"mysql+pymysql://{db_config['user']}:{db_config['password']}@{db_config['host']}:{db_config['port']}/{db_config['database']}"
        
        jobstores = {
            'default': SQLAlchemyJobStore(url=jobstore_url)
        }
        
        # Initialize scheduler
        self.scheduler = BackgroundScheduler(jobstores=jobstores)
        self.archival_engine = ArchivalEngine(db_config)
        
        # Register shutdown handler
        atexit.register(lambda: self.scheduler.shutdown())
    
    def start(self):
        """Start the scheduler"""
        try:
            self.scheduler.start()
            self.logger.info("Scheduler started successfully")
            self._load_existing_schedules()
        except Exception as e:
            self.logger.error(f"Failed to start scheduler: {e}")
            raise
    
    def stop(self):
        """Stop the scheduler"""
        self.scheduler.shutdown()
        self.logger.info("Scheduler stopped")
    
    def add_schedule(self, job_name: str, cron_expression: str, policy_id: int, table_name: str):
        """Add a new scheduled job"""
        try:
            # Parse cron expression
            cron_parts = cron_expression.split()
            if len(cron_parts) != 5:
                raise ValueError("Invalid cron expression format")
            
            # Add job to scheduler
            self.scheduler.add_job(
                func=self._execute_archival_job,
                trigger=CronTrigger.from_crontab(cron_expression),
                args=[job_name, policy_id, table_name],
                id=job_name,
                name=job_name,
                replace_existing=True
            )
            
            self.logger.info(f"Schedule added for job: {job_name}")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to add schedule for {job_name}: {e}")
            return False
    
    def remove_schedule(self, job_name: str):
        """Remove a scheduled job"""
        try:
            self.scheduler.remove_job(job_name)
            self.logger.info(f"Schedule removed for job: {job_name}")
            return True
        except Exception as e:
            self.logger.error(f"Failed to remove schedule for {job_name}: {e}")
            return False
    
    def pause_schedule(self, job_name: str):
        """Pause a scheduled job"""
        try:
            self.scheduler.pause_job(job_name)
            self.logger.info(f"Schedule paused for job: {job_name}")
            return True
        except Exception as e:
            self.logger.error(f"Failed to pause schedule for {job_name}: {e}")
            return False
    
    def resume_schedule(self, job_name: str):
        """Resume a paused job"""
        try:
            self.scheduler.resume_job(job_name)
            self.logger.info(f"Schedule resumed for job: {job_name}")
            return True
        except Exception as e:
            self.logger.error(f"Failed to resume schedule for {job_name}: {e}")
            return False
    
    def execute_job_now(self, job_name: str, policy_id: int, table_name: str):
        """Execute a job immediately"""
        try:
            self.scheduler.add_job(
                func=self._execute_archival_job,
                trigger='date',
                args=[job_name, policy_id, table_name],
                id=f"{job_name}_manual_{datetime.now().timestamp()}",
                name=f"{job_name}_manual"
            )
            self.logger.info(f"Manual execution triggered for job: {job_name}")
            return True
        except Exception as e:
            self.logger.error(f"Failed to execute job {job_name} manually: {e}")
            return False
    
    def _execute_archival_job(self, job_name: str, policy_id: int, table_name: str):
        """Execute archival job"""
        try:
            # Create job record
            job = self._create_job_record(job_name, table_name, policy_id)
            
            # Execute archival
            success = self.archival_engine.execute_archival_job(job)
            
            if success:
                self.logger.info(f"Job {job_name} executed successfully")
            else:
                self.logger.error(f"Job {job_name} execution failed")
                
        except Exception as e:
            self.logger.error(f"Error executing job {job_name}: {e}")
    
    def _create_job_record(self, job_name: str, table_name: str, policy_id: int) -> ArchivalJob:
        """Create job record in database"""
        conn = self.archival_engine.get_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute("""
                INSERT INTO archival_jobs (job_name, table_name, policy_id, status)
                VALUES (%s, %s, %s, 'pending')
            """, (job_name, table_name, policy_id))
            
            job_id = cursor.lastrowid
            conn.commit()
            
            return ArchivalJob(
                id=job_id,
                job_name=job_name,
                table_name=table_name,
                policy_id=policy_id,
                status='pending'
            )
            
        finally:
            conn.close()
    
    def _load_existing_schedules(self):
        """Load existing schedules from database"""
        conn = self.archival_engine.get_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute("""
                SELECT sc.job_name, sc.cron_expression, sc.is_active, ap.id as policy_id, ap.table_name
                FROM scheduler_config sc
                JOIN archival_policies ap ON sc.job_name = CONCAT('archive_', ap.table_name)
                WHERE sc.is_active = TRUE
            """)
            
            schedules = cursor.fetchall()
            
            for schedule in schedules:
                job_name, cron_expression, is_active, policy_id, table_name = schedule
                if is_active:
                    self.add_schedule(job_name, cron_expression, policy_id, table_name)
                    
        finally:
            conn.close()
```

## 3. Admin Dashboard Implementation (React/TypeScript)

```typescript
// AdminDashboard.tsx
import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';

interface Job {
  id: number;
  job_name: string;
  table_name: string;
  status: 'pending' | 'running' | 'completed' | 'failed' | 'cancelled';
  started_at: string | null;
  completed_at: string | null;
  records_processed: number;
  records_archived: number;
  error_message: string | null;
}

interface DashboardStats {
  total_jobs: number;
  successful_jobs: number;
  failed_jobs: number;
  running_jobs: number;
  success_rate: number;
}

export const AdminDashboard: React.FC = () => {
  const [jobs, setJobs] = useState<Job[]>([]);
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardData();
    const interval = setInterval(fetchDashboardData, 5000); // Refresh every 5 seconds
    return () => clearInterval(interval);
  }, []);

  const fetchDashboardData = async () => {
    try {
      const [jobsResponse, statsResponse] = await Promise.all([
        fetch('/api/archival/v1/jobs?limit=10'),
        fetch('/api/archival/v1/metrics')
      ]);

      const jobsData = await jobsResponse.json();
      const statsData = await statsResponse.json();

      setJobs(jobsData.data);
      setStats(statsData.data);
      setLoading(false);
    } catch (error) {
      console.error('Failed to fetch dashboard data:', error);
      setLoading(false);
    }
  };

  const getStatusBadge = (status: string) => {
    const statusConfig = {
      pending: { color: 'bg-yellow-100 text-yellow-800', label: 'Pending' },
      running: { color: 'bg-blue-100 text-blue-800', label: 'Running' },
      completed: { color: 'bg-green-100 text-green-800', label: 'Completed' },
      failed: { color: 'bg-red-100 text-red-800', label: 'Failed' },
      cancelled: { color: 'bg-gray-100 text-gray-800', label: 'Cancelled' }
    };

    const config = statusConfig[status as keyof typeof statusConfig];
    return <Badge className={config.color}>{config.label}</Badge>;
  };

  const formatDateTime = (dateString: string | null) => {
    if (!dateString) return 'N/A';
    return new Date(dateString).toLocaleString();
  };

  if (loading) {
    return <div className="flex justify-center items-center h-64">Loading...</div>;
  }

  return (
    <div className="container mx-auto p-6">
      <h1 className="text-3xl font-bold mb-6">Data Archival Dashboard</h1>
      
      {/* Stats Overview */}
      {stats && (
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium">Total Jobs</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.total_jobs}</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium">Success Rate</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.success_rate.toFixed(1)}%</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium">Running Jobs</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.running_jobs}</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium">Failed Jobs</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-red-600">{stats.failed_jobs}</div>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Jobs Table */}
      <Card>
        <CardHeader>
          <CardTitle>Recent Jobs</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full table-auto">
              <thead>
                <tr className="border-b">
                  <th className="text-left p-2">Job Name</th>
                  <th className="text-left p-2">Table</th>
                  <th className="text-left p-2">Status</th>
                  <th className="text-left p-2">Progress</th>
                  <th className="text-left p-2">Records Processed</th>
                  <th className="text-left p-2">Started At</th>
                  <th className="text-left p-2">Completed At</th>
                  <th className="text-left p-2">Actions</th>
                </tr>
              </thead>
              <tbody>
                {jobs.map((job) => (
                  <tr key={job.id} className="border-b">
                    <td className="p-2 font-medium">{job.job_name}</td>
                    <td className="p-2">{job.table_name}</td>
                    <td className="p-2">{getStatusBadge(job.status)}</td>
                    <td className="p-2">
                      {job.status === 'running' && (
                        <div className="w-full">
                          <Progress value={75} className="h-2" />
                          <span className="text-xs text-gray-500">75%</span>
                        </div>
                      )}
                    </td>
                    <td className="p-2">{job.records_processed.toLocaleString()}</td>
                    <td className="p-2">{formatDateTime(job.started_at)}</td>
                    <td className="p-2">{formatDateTime(job.completed_at)}</td>
                    <td className="p-2">
                      <div className="flex space-x-2">
                        <Button size="sm" variant="outline">
                          View Details
                        </Button>
                        {job.status === 'running' && (
                          <Button size="sm" variant="destructive">
                            Cancel
                          </Button>
                        )}
                        {job.status === 'failed' && (
                          <Button size="sm" variant="default">
                            Retry
                          </Button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};
```

## 4. Exception Handling Implementation

```python
import logging
import traceback
from typing import Dict, Any, Optional
from enum import Enum
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

class ErrorSeverity(Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"

class ArchivalException(Exception):
    def __init__(self, message: str, severity: ErrorSeverity = ErrorSeverity.MEDIUM, 
                 error_code: str = None, details: Dict[str, Any] = None):
        super().__init__(message)
        self.severity = severity
        self.error_code = error_code
        self.details = details or {}

class ExceptionHandler:
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.logger = logging.getLogger(__name__)
        self.alert_manager = AlertManager(config.get('alerts', {}))
    
    def handle_exception(self, exception: Exception, context: Dict[str, Any] = None):
        """Main exception handling entry point"""
        context = context or {}
        
        # Log the exception
        self._log_exception(exception, context)
        
        # Determine if alerting is needed
        if isinstance(exception, ArchivalException):
            if exception.severity in [ErrorSeverity.HIGH, ErrorSeverity.CRITICAL]:
                self.alert_manager.send_alert(exception, context)
        else:
            # Generic exception - treat as medium severity
            self.alert_manager.send_alert(exception, context, ErrorSeverity.MEDIUM)
        
        # Attempt recovery if possible
        if isinstance(exception, ArchivalException):
            self._attempt_recovery(exception, context)
    
    def _log_exception(self, exception: Exception, context: Dict[str, Any]):
        """Log exception with full context"""
        log_data = {
            'exception_type': type(exception).__name__,
            'message': str(exception),
            'traceback': traceback.format_exc(),
            'context': context,
            'timestamp': datetime.now().isoformat()
        }
        
        if isinstance(exception, ArchivalException):
            log_data.update({
                'severity': exception.severity.value,
                'error_code': exception.error_code,
                'details': exception.details
            })
            
            if exception.severity == ErrorSeverity.CRITICAL:
                self.logger.critical(f"Critical error: {log_data}")
            elif exception.severity == ErrorSeverity.HIGH:
                self.logger.error(f"High severity error: {log_data}")
            elif exception.severity == ErrorSeverity.MEDIUM:
                self.logger.warning(f"Medium severity error: {log_data}")
            else:
                self.logger.info(f"Low severity error: {log_data}")
        else:
            self.logger.error(f"Unexpected error: {log_data}")
    
    def _attempt_recovery(self, exception: ArchivalException, context: Dict[str, Any]):
        """Attempt to recover from the exception"""
        recovery_strategies = {
            'database_connection_error': self._recover_database_connection,
            'insufficient_memory': self._recover_memory_issue,
            'disk_space_full': self._recover_disk_space,
            'timeout_error': self._recover_timeout,
            'data_integrity_error': self._recover_data_integrity
        }
        
        error_code = exception.error_code
        if error_code and error_code in recovery_strategies:
            try:
                recovery_strategies[error_code](exception, context)
            except Exception as recovery_error:
                self.logger.error(f"Recovery failed for {error_code}: {recovery_error}")
    
    def _recover_database_connection(self, exception: ArchivalException, context: Dict[str, Any]):
        """Recover from database connection issues"""
        self.logger.info("Attempting database connection recovery...")
        # Implement connection retry logic
        # Reset connection pool
        # Update job status to retry
    
    def _recover_memory_issue(self, exception: ArchivalException, context: Dict[str, Any]):
        """Recover from memory issues"""
        self.logger.info("Attempting memory issue recovery...")
        # Reduce batch size
        # Clear caches
        # Suggest manual intervention
    
    def _recover_disk_space(self, exception: ArchivalException, context: Dict[str, Any]):
        """Recover from disk space issues"""
        self.logger.info("Attempting disk space recovery...")
        # Clean up temporary files
        # Compress existing archives
        # Alert administrators
    
    def _recover_timeout(self, exception: ArchivalException, context: Dict[str, Any]):
        """Recover from timeout issues"""
        self.logger.info("Attempting timeout recovery...")
        # Increase timeout settings
        # Break job into smaller chunks
        # Reschedule for off-peak hours
    
    def _recover_data_integrity(self, exception: ArchivalException, context: Dict[str, Any]):
        """Recover from data integrity issues"""
        self.logger.info("Attempting data integrity recovery...")
        # Validate data before processing
        # Skip problematic records
        # Create detailed error report

class AlertManager:
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.logger = logging.getLogger(__name__)
    
    def send_alert(self, exception: Exception, context: Dict[str, Any], 
                   severity: ErrorSeverity = None):
        """Send alert based on exception severity"""
        if isinstance(exception, ArchivalException):
            severity = exception.severity
        elif severity is None:
            severity = ErrorSeverity.MEDIUM
        
        # Send email alert for high/critical severity
        if severity in [ErrorSeverity.HIGH, ErrorSeverity.CRITICAL]:
            self._send_email_alert(exception, context, severity)
        
        # Send Slack notification for critical issues
        if severity == ErrorSeverity.CRITICAL:
            self._send_slack_alert(exception, context)
        
        # Log to external monitoring system
        self._log_to_monitoring(exception, context, severity)
    
    def _send_email_alert(self, exception: Exception, context: Dict[str, Any], 
                         severity: ErrorSeverity):
        """Send email alert"""
        try:
            smtp_config = self.config.get('smtp', {})
            if not smtp_config:
                return
            
            msg = MIMEMultipart()
            msg['From'] = smtp_config['from_email']
            msg['To'] = ', '.join(smtp_config['alert_recipients'])
            msg['Subject'] = f"Archival System Alert - {severity.value.upper()}"
            
            body = self._format_email_body(exception, context, severity)
            msg.attach(MIMEText(body, 'html'))
            
            server = smtplib.SMTP(smtp_config['host'], smtp_config['port'])
            server.starttls()
            server.login(smtp_config['username'], smtp_config['password'])
            server.send_message(msg)
            server.quit()
            
            self.logger.info(f"Email alert sent for {severity.value} error")
            
        except Exception as e:
            self.logger.error(f"Failed to send email alert: {e}")
    
    def _format_email_body(self, exception: Exception, context: Dict[str, Any], 
                          severity: ErrorSeverity) -> str:
        """Format email body with error details"""
        return f"""
        <html>
        <body>
            <h2>Archival System Alert</h2>
            <p><strong>Severity:</strong> {severity.value.upper()}</p>
            <p><strong>Time:</strong> {datetime.now().isoformat()}</p>
            <p><strong>Error:</strong> {str(exception)}</p>
            <p><strong>Context:</strong></p>
            <pre>{json.dumps(context, indent=2)}</pre>
            <p><strong>Traceback:</strong></p>
            <pre>{traceback.format_exc()}</pre>
        </body>
        </html>
        """
    
    def _send_slack_alert(self, exception: Exception, context: Dict[str, Any]):
        """Send Slack notification for critical issues"""
        # Implement Slack webhook notification
        pass
    
    def _log_to_monitoring(self, exception: Exception, context: Dict[str, Any], 
                          severity: ErrorSeverity):
        """Log to external monitoring system"""
        # Implement integration with monitoring systems like DataDog, New Relic, etc.
        pass
```

## 5. Database Migration Scripts

```sql
-- Migration: Create archival system tables
-- Version: 1.0.0
-- Date: 2024-01-15

-- Create archival policies table
CREATE TABLE IF NOT EXISTS archival_policies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(100) NOT NULL,
    retention_days INT NOT NULL,
    archival_method ENUM('soft_delete', 'hard_delete', 'partition_move') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_table_name (table_name),
    INDEX idx_is_active (is_active)
);

-- Create archival jobs table
CREATE TABLE IF NOT EXISTS archival_jobs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    job_name VARCHAR(100) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    status ENUM('pending', 'running', 'completed', 'failed', 'cancelled') DEFAULT 'pending',
    policy_id INT NOT NULL,
    started_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    records_processed INT DEFAULT 0,
    records_archived INT DEFAULT 0,
    error_message TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (policy_id) REFERENCES archival_policies(id) ON DELETE CASCADE,
    INDEX idx_status (status),
    INDEX idx_table_name (table_name),
    INDEX idx_created_at (created_at)
);

-- Create archival logs table
CREATE TABLE IF NOT EXISTS archival_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    job_id INT NOT NULL,
    log_level ENUM('INFO', 'WARN', 'ERROR', 'DEBUG') NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES archival_jobs(id) ON DELETE CASCADE,
    INDEX idx_job_id (job_id),
    INDEX idx_log_level (log_level),
    INDEX idx_created_at (created_at)
);

-- Create scheduler configuration table
CREATE TABLE IF NOT EXISTS scheduler_config (
    id INT PRIMARY KEY AUTO_INCREMENT,
    job_name VARCHAR(100) UNIQUE NOT NULL,
    cron_expression VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    next_run_at TIMESTAMP NULL,
    last_run_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_is_active (is_active),
    INDEX idx_next_run_at (next_run_at)
);

-- Create system metrics table
CREATE TABLE IF NOT EXISTS system_metrics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(15,2) NOT NULL,
    metric_unit VARCHAR(20) NOT NULL,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_metric_name (metric_name),
    INDEX idx_recorded_at (recorded_at)
);

-- Insert default archival policies
INSERT INTO archival_policies (table_name, retention_days, archival_method, is_active) VALUES
('transactions', 365, 'soft_delete', TRUE),
('user_sessions', 90, 'hard_delete', TRUE),
('audit_logs', 730, 'partition_move', TRUE),
('error_logs', 180, 'hard_delete', TRUE);

-- Create indexes for performance
CREATE INDEX idx_archival_jobs_status_created ON archival_jobs(status, created_at);
CREATE INDEX idx_archival_logs_job_level ON archival_logs(job_id, log_level);
CREATE INDEX idx_scheduler_config_active_next ON scheduler_config(is_active, next_run_at);
```

This comprehensive implementation provides a complete data archival and purging system with admin interfaces, scheduler management, and robust exception handling for MySQL databases.