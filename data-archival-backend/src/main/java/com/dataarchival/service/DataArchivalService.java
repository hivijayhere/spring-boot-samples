package com.dataarchival.service;

import com.dataarchival.entity.JobExecutionHistory;
import com.dataarchival.entity.TableConfig;
import com.dataarchival.repository.TableConfigRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.sql.DataSource;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
@Transactional
public class DataArchivalService {
    
    @Autowired
    private TableConfigRepository tableConfigRepository;
    
    @Autowired
    private JobExecutionService jobExecutionService;
    
    @Autowired
    @Qualifier("archivalDataSource")
    private DataSource archivalDataSource;
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    private JdbcTemplate archivalJdbcTemplate;
    
    @Autowired
    public void setArchivalJdbcTemplate(@Qualifier("archivalDataSource") DataSource archivalDataSource) {
        this.archivalJdbcTemplate = new JdbcTemplate(archivalDataSource);
    }
    
    public void executeArchivalJob(String tableName) {
        TableConfig tableConfig = tableConfigRepository.findByTableName(tableName)
                .orElseThrow(() -> new IllegalArgumentException("Table configuration not found: " + tableName));
        
        if (!tableConfig.getIsActive()) {
            throw new IllegalStateException("Table configuration is inactive: " + tableName);
        }
        
        // Create job execution record
        JobExecutionDTO jobExecution = jobExecutionService.createJobExecution(tableName, JobExecutionHistory.JobType.ARCHIVE);
        Long jobId = jobExecution.getId();
        
        try {
            // Update job status to running
            jobExecutionService.updateJobStatus(jobId, JobExecutionHistory.JobStatus.RUNNING);
            
            // Calculate cutoff date
            LocalDateTime cutoffDate = LocalDateTime.now().minusDays(tableConfig.getArchivalDays());
            
            // Get records to archive
            String countQuery = "SELECT COUNT(*) FROM " + tableName + " WHERE created_at < ?";
            Integer totalRecords = jdbcTemplate.queryForObject(countQuery, Integer.class, cutoffDate);
            
            if (totalRecords == null || totalRecords == 0) {
                jobExecutionService.updateJobStatus(jobId, JobExecutionHistory.JobStatus.COMPLETED);
                return;
            }
            
            // Create archival table if it doesn't exist
            createArchivalTableIfNotExists(tableName);
            
            // Archive records
            String archiveQuery = "INSERT INTO " + tableName + "_archive SELECT * FROM " + tableName + " WHERE created_at < ?";
            int archivedRecords = jdbcTemplate.update(archiveQuery, cutoffDate);
            
            // Delete archived records from live table
            String deleteQuery = "DELETE FROM " + tableName + " WHERE created_at < ?";
            int deletedRecords = jdbcTemplate.update(deleteQuery, cutoffDate);
            
            // Update job metrics
            jobExecutionService.updateJobMetrics(jobId, totalRecords, archivedRecords, 0);
            jobExecutionService.updateJobStatus(jobId, JobExecutionHistory.JobStatus.COMPLETED);
            
        } catch (Exception e) {
            jobExecutionService.updateJobError(jobId, e.getMessage());
            throw new RuntimeException("Archival job failed for table: " + tableName, e);
        }
    }
    
    public void executePurgeJob(String tableName) {
        TableConfig tableConfig = tableConfigRepository.findByTableName(tableName)
                .orElseThrow(() -> new IllegalArgumentException("Table configuration not found: " + tableName));
        
        if (!tableConfig.getIsActive()) {
            throw new IllegalStateException("Table configuration is inactive: " + tableName);
        }
        
        // Create job execution record
        JobExecutionDTO jobExecution = jobExecutionService.createJobExecution(tableName, JobExecutionHistory.JobType.PURGE);
        Long jobId = jobExecution.getId();
        
        try {
            // Update job status to running
            jobExecutionService.updateJobStatus(jobId, JobExecutionHistory.JobStatus.RUNNING);
            
            // Calculate cutoff date
            LocalDateTime cutoffDate = LocalDateTime.now().minusDays(tableConfig.getPurgeDays());
            
            // Get records to purge from archival table
            String countQuery = "SELECT COUNT(*) FROM " + tableName + "_archive WHERE created_at < ?";
            Integer totalRecords = archivalJdbcTemplate.queryForObject(countQuery, Integer.class, cutoffDate);
            
            if (totalRecords == null || totalRecords == 0) {
                jobExecutionService.updateJobStatus(jobId, JobExecutionHistory.JobStatus.COMPLETED);
                return;
            }
            
            // Purge records from archival table
            String purgeQuery = "DELETE FROM " + tableName + "_archive WHERE created_at < ?";
            int purgedRecords = archivalJdbcTemplate.update(purgeQuery, cutoffDate);
            
            // Update job metrics
            jobExecutionService.updateJobMetrics(jobId, totalRecords, 0, purgedRecords);
            jobExecutionService.updateJobStatus(jobId, JobExecutionHistory.JobStatus.COMPLETED);
            
        } catch (Exception e) {
            jobExecutionService.updateJobError(jobId, e.getMessage());
            throw new RuntimeException("Purge job failed for table: " + tableName, e);
        }
    }
    
    public Map<String, Object> previewArchivalData(String tableName, Integer days) {
        LocalDateTime cutoffDate = LocalDateTime.now().minusDays(days);
        
        String countQuery = "SELECT COUNT(*) FROM " + tableName + " WHERE created_at < ?";
        Integer recordCount = jdbcTemplate.queryForObject(countQuery, Integer.class, cutoffDate);
        
        String sampleQuery = "SELECT * FROM " + tableName + " WHERE created_at < ? LIMIT 10";
        List<Map<String, Object>> sampleRecords = jdbcTemplate.queryForList(sampleQuery, cutoffDate);
        
        return Map.of(
            "tableName", tableName,
            "cutoffDate", cutoffDate,
            "recordCount", recordCount != null ? recordCount : 0,
            "sampleRecords", sampleRecords
        );
    }
    
    public Map<String, Object> previewPurgeData(String tableName, Integer days) {
        LocalDateTime cutoffDate = LocalDateTime.now().minusDays(days);
        
        String countQuery = "SELECT COUNT(*) FROM " + tableName + "_archive WHERE created_at < ?";
        Integer recordCount = archivalJdbcTemplate.queryForObject(countQuery, Integer.class, cutoffDate);
        
        String sampleQuery = "SELECT * FROM " + tableName + "_archive WHERE created_at < ? LIMIT 10";
        List<Map<String, Object>> sampleRecords = archivalJdbcTemplate.queryForList(sampleQuery, cutoffDate);
        
        return Map.of(
            "tableName", tableName,
            "cutoffDate", cutoffDate,
            "recordCount", recordCount != null ? recordCount : 0,
            "sampleRecords", sampleRecords
        );
    }
    
    private void createArchivalTableIfNotExists(String tableName) {
        // Get table structure from live database
        String createTableQuery = "SHOW CREATE TABLE " + tableName;
        Map<String, Object> result = jdbcTemplate.queryForMap(createTableQuery);
        String createStatement = (String) result.get("Create Table");
        
        // Modify table name for archival
        String archivalCreateStatement = createStatement.replace("CREATE TABLE `" + tableName + "`", 
                                                               "CREATE TABLE `" + tableName + "_archive`");
        
        // Create table in archival database
        try {
            archivalJdbcTemplate.execute(archivalCreateStatement);
        } catch (Exception e) {
            // Table might already exist, ignore error
            System.out.println("Archival table might already exist: " + e.getMessage());
        }
    }
}