package com.dataarchival.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDateTime;

public class TableConfigDTO {
    
    private Long id;
    
    @NotBlank(message = "Table name is required")
    private String tableName;
    
    @NotNull(message = "Archival days is required")
    @Min(value = 1, message = "Archival days must be at least 1")
    private Integer archivalDays;
    
    @NotNull(message = "Purge days is required")
    @Min(value = 1, message = "Purge days must be at least 1")
    private Integer purgeDays;
    
    private Boolean isActive;
    
    private LocalDateTime createdAt;
    
    private LocalDateTime updatedAt;
    
    // Constructors
    public TableConfigDTO() {}
    
    public TableConfigDTO(String tableName, Integer archivalDays, Integer purgeDays) {
        this.tableName = tableName;
        this.archivalDays = archivalDays;
        this.purgeDays = purgeDays;
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
    
    public Integer getArchivalDays() {
        return archivalDays;
    }
    
    public void setArchivalDays(Integer archivalDays) {
        this.archivalDays = archivalDays;
    }
    
    public Integer getPurgeDays() {
        return purgeDays;
    }
    
    public void setPurgeDays(Integer purgeDays) {
        this.purgeDays = purgeDays;
    }
    
    public Boolean getIsActive() {
        return isActive;
    }
    
    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}