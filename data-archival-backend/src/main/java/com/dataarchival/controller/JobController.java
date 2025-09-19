package com.dataarchival.controller;

import com.dataarchival.dto.JobExecutionDTO;
import com.dataarchival.entity.JobExecutionHistory;
import com.dataarchival.service.JobExecutionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/v1/jobs")
@CrossOrigin(origins = "*")
public class JobController {
    
    @Autowired
    private JobExecutionService jobExecutionService;
    
    @GetMapping("/status")
    public ResponseEntity<List<JobExecutionDTO>> getJobStatus() {
        List<JobExecutionDTO> runningJobs = jobExecutionService.getJobExecutionsByStatus(JobExecutionHistory.JobStatus.RUNNING);
        return ResponseEntity.ok(runningJobs);
    }
    
    @GetMapping("/history")
    public ResponseEntity<Page<JobExecutionDTO>> getJobHistory(
            @RequestParam(required = false) String tableName,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        Page<JobExecutionDTO> jobHistory;
        
        if (tableName != null && !tableName.isEmpty()) {
            jobHistory = jobExecutionService.getJobExecutionsByTableName(tableName, pageable);
        } else {
            // Return all jobs with pagination
            jobHistory = jobExecutionService.getJobExecutionsByTableName("", pageable);
        }
        
        return ResponseEntity.ok(jobHistory);
    }
    
    @GetMapping("/history/{tableName}")
    public ResponseEntity<List<JobExecutionDTO>> getJobHistoryByTableName(@PathVariable String tableName) {
        List<JobExecutionDTO> jobHistory = jobExecutionService.getJobExecutionsByTableName(tableName);
        return ResponseEntity.ok(jobHistory);
    }
    
    @GetMapping("/history/{tableName}/{jobType}")
    public ResponseEntity<List<JobExecutionDTO>> getJobHistoryByTableNameAndJobType(
            @PathVariable String tableName, 
            @PathVariable String jobType) {
        
        JobExecutionHistory.JobType jobTypeEnum = JobExecutionHistory.JobType.valueOf(jobType.toUpperCase());
        List<JobExecutionDTO> jobHistory = jobExecutionService.getJobExecutionsByTableNameAndJobType(tableName, jobTypeEnum);
        return ResponseEntity.ok(jobHistory);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<JobExecutionDTO> getJobExecutionById(@PathVariable Long id) {
        return jobExecutionService.getJobExecutionById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/stats")
    public ResponseEntity<Object> getJobStats() {
        Long activeJobs = jobExecutionService.getJobCountByStatus(JobExecutionHistory.JobStatus.RUNNING);
        Long completedJobs = jobExecutionService.getJobCountByStatus(JobExecutionHistory.JobStatus.COMPLETED);
        Long failedJobs = jobExecutionService.getJobCountByStatus(JobExecutionHistory.JobStatus.FAILED);
        Long totalArchived = jobExecutionService.getTotalArchivedRecords();
        Long totalPurged = jobExecutionService.getTotalPurgedRecords();
        
        return ResponseEntity.ok(new Object() {
            public final Long activeJobs = activeJobs;
            public final Long completedJobs = completedJobs;
            public final Long failedJobs = failedJobs;
            public final Long totalArchived = totalArchived;
            public final Long totalPurged = totalPurged;
        });
    }
}