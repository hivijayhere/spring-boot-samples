package com.dataarchival.dto;

import java.time.LocalDateTime;

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
    private LocalDateTime createdAt;
    
    // Constructors
    public JobExecutionDTO() {}
    
    public JobExecutionDTO(Long id, String tableName, String jobType, String status) {
        this.id = id;
        this.tableName = tableName;
        this.jobType = jobType;
        this.status = status;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getTableName() {
        return tableName;
    }
    
    public void setTableName(String tableName) {
        this.tableName = tableName;
    }
    
    public String getJobType() {
        return jobType;
    }
    
    public void setJobType(String jobType) {
        this.jobType = jobType;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public Integer getRecordsProcessed() {
        return recordsProcessed;
    }
    
    public void setRecordsProcessed(Integer recordsProcessed) {
        this.recordsProcessed = recordsProcessed;
    }
    
    public Integer getRecordsArchived() {
        return recordsArchived;
    }
    
    public void setRecordsArchived(Integer recordsArchived) {
        this.recordsArchived = recordsArchived;
    }
    
    public Integer getRecordsPurged() {
        return recordsPurged;
    }
    
    public void setRecordsPurged(Integer recordsPurged) {
        this.recordsPurged = recordsPurged;
    }
    
    public LocalDateTime getStartTime() {
        return startTime;
    }
    
    public void setStartTime(LocalDateTime startTime) {
        this.startTime = startTime;
    }
    
    public LocalDateTime getEndTime() {
        return endTime;
    }
    
    public void setEndTime(LocalDateTime endTime) {
        this.endTime = endTime;
    }
    
    public String getErrorMessage() {
        return errorMessage;
    }
    
    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}