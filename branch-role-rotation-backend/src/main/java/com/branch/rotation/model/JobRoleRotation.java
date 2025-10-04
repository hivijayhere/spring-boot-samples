package com.branch.rotation.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "job_role_rotations")
public class JobRoleRotation {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @NotNull
    private User user;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "job_role_id", nullable = false)
    @NotNull
    private JobRole jobRole;
    
    @Column(name = "branch_code", nullable = false)
    @NotBlank
    @Size(max = 20)
    private String branchCode;
    
    @Column(name = "branch_name", nullable = false)
    @NotBlank
    @Size(max = 255)
    private String branchName;
    
    @Column(name = "effective_from", nullable = false)
    @NotNull
    private LocalDate effectiveFrom;
    
    @Column(name = "effective_to")
    private LocalDate effectiveTo;
    
    @Column(name = "is_current")
    private Boolean isCurrent = false;
    
    @Column(name = "created_by")
    @Size(max = 100)
    private String createdBy;
    
    @CreationTimestamp
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // Constructors
    public JobRoleRotation() {}
    
    public JobRoleRotation(User user, JobRole jobRole, String branchCode, String branchName, 
                          LocalDate effectiveFrom, String createdBy) {
        this.user = user;
        this.jobRole = jobRole;
        this.branchCode = branchCode;
        this.branchName = branchName;
        this.effectiveFrom = effectiveFrom;
        this.createdBy = createdBy;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public User getUser() {
        return user;
    }
    
    public void setUser(User user) {
        this.user = user;
    }
    
    public JobRole getJobRole() {
        return jobRole;
    }
    
    public void setJobRole(JobRole jobRole) {
        this.jobRole = jobRole;
    }
    
    public String getBranchCode() {
        return branchCode;
    }
    
    public void setBranchCode(String branchCode) {
        this.branchCode = branchCode;
    }
    
    public String getBranchName() {
        return branchName;
    }
    
    public void setBranchName(String branchName) {
        this.branchName = branchName;
    }
    
    public LocalDate getEffectiveFrom() {
        return effectiveFrom;
    }
    
    public void setEffectiveFrom(LocalDate effectiveFrom) {
        this.effectiveFrom = effectiveFrom;
    }
    
    public LocalDate getEffectiveTo() {
        return effectiveTo;
    }
    
    public void setEffectiveTo(LocalDate effectiveTo) {
        this.effectiveTo = effectiveTo;
    }
    
    public Boolean getIsCurrent() {
        return isCurrent;
    }
    
    public void setIsCurrent(Boolean isCurrent) {
        this.isCurrent = isCurrent;
    }
    
    public String getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
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