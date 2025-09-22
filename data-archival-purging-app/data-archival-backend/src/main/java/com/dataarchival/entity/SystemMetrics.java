package com.dataarchival.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "system_metrics")
public class SystemMetrics {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank(message = "Table name is required")
    @Column(name = "table_name", nullable = false)
    private String tableName;
    
    @Column(name = "total_records")
    private Long totalRecords = 0L;
    
    @Column(name = "archived_records")
    private Long archivedRecords = 0L;
    
    @Column(name = "purged_records")
    private Long purgedRecords = 0L;
    
    @Column(name = "last_archival_date")
    private LocalDateTime lastArchivalDate;
    
    @Column(name = "last_purge_date")
    private LocalDateTime lastPurgeDate;
    
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    // Constructors
    public SystemMetrics() {}
    
    public SystemMetrics(String tableName) {
        this.tableName = tableName;
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
    
    public Long getTotalRecords() {
        return totalRecords;
    }
    
    public void setTotalRecords(Long totalRecords) {
        this.totalRecords = totalRecords;
    }
    
    public Long getArchivedRecords() {
        return archivedRecords;
    }
    
    public void setArchivedRecords(Long archivedRecords) {
        this.archivedRecords = archivedRecords;
    }
    
    public Long getPurgedRecords() {
        return purgedRecords;
    }
    
    public void setPurgedRecords(Long purgedRecords) {
        this.purgedRecords = purgedRecords;
    }
    
    public LocalDateTime getLastArchivalDate() {
        return lastArchivalDate;
    }
    
    public void setLastArchivalDate(LocalDateTime lastArchivalDate) {
        this.lastArchivalDate = lastArchivalDate;
    }
    
    public LocalDateTime getLastPurgeDate() {
        return lastPurgeDate;
    }
    
    public void setLastPurgeDate(LocalDateTime lastPurgeDate) {
        this.lastPurgeDate = lastPurgeDate;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}