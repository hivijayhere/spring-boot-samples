package com.dataarchival.dto;

import java.time.LocalDateTime;

public class SystemMetricsDTO {
    
    private Long totalTables;
    private Long activeJobs;
    private Long completedJobs;
    private Long failedJobs;
    private Long totalRecordsArchived;
    private Long totalRecordsPurged;
    private LocalDateTime lastExecutionTime;
    
    // Constructors
    public SystemMetricsDTO() {}
    
    public SystemMetricsDTO(Long totalTables, Long activeJobs, Long completedJobs, Long failedJobs,
                           Long totalRecordsArchived, Long totalRecordsPurged, LocalDateTime lastExecutionTime) {
        this.totalTables = totalTables;
        this.activeJobs = activeJobs;
        this.completedJobs = completedJobs;
        this.failedJobs = failedJobs;
        this.totalRecordsArchived = totalRecordsArchived;
        this.totalRecordsPurged = totalRecordsPurged;
        this.lastExecutionTime = lastExecutionTime;
    }
    
    // Getters and Setters
    public Long getTotalTables() {
        return totalTables;
    }
    
    public void setTotalTables(Long totalTables) {
        this.totalTables = totalTables;
    }
    
    public Long getActiveJobs() {
        return activeJobs;
    }
    
    public void setActiveJobs(Long activeJobs) {
        this.activeJobs = activeJobs;
    }
    
    public Long getCompletedJobs() {
        return completedJobs;
    }
    
    public void setCompletedJobs(Long completedJobs) {
        this.completedJobs = completedJobs;
    }
    
    public Long getFailedJobs() {
        return failedJobs;
    }
    
    public void setFailedJobs(Long failedJobs) {
        this.failedJobs = failedJobs;
    }
    
    public Long getTotalRecordsArchived() {
        return totalRecordsArchived;
    }
    
    public void setTotalRecordsArchived(Long totalRecordsArchived) {
        this.totalRecordsArchived = totalRecordsArchived;
    }
    
    public Long getTotalRecordsPurged() {
        return totalRecordsPurged;
    }
    
    public void setTotalRecordsPurged(Long totalRecordsPurged) {
        this.totalRecordsPurged = totalRecordsPurged;
    }
    
    public LocalDateTime getLastExecutionTime() {
        return lastExecutionTime;
    }
    
    public void setLastExecutionTime(LocalDateTime lastExecutionTime) {
        this.lastExecutionTime = lastExecutionTime;
    }
}