package com.dataarchival.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "table_config")
public class TableConfig {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank(message = "Table name is required")
    @Column(name = "table_name", unique = true, nullable = false)
    private String tableName;
    
    @NotNull(message = "Archival days is required")
    @Min(value = 1, message = "Archival days must be at least 1")
    @Column(name = "archival_days", nullable = false)
    private Integer archivalDays;
    
    @NotNull(message = "Purge days is required")
    @Min(value = 1, message = "Purge days must be at least 1")
    @Column(name = "purge_days", nullable = false)
    private Integer purgeDays;
    
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    // Constructors
    public TableConfig() {}
    
    public TableConfig(String tableName, Integer archivalDays, Integer purgeDays) {
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