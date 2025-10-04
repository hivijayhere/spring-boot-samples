package com.branch.rotation.dto;

import com.branch.rotation.model.RoleType;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class JobRoleRotationDto {
    
    private Long id;
    private Long userId;
    private String userFullName;
    private String employeeId;
    private Long jobRoleId;
    private String roleCode;
    private String roleName;
    private RoleType roleType;
    private String branchCode;
    private String branchName;
    private LocalDate effectiveFrom;
    private LocalDate effectiveTo;
    private Boolean isCurrent;
    private String createdBy;
    private LocalDateTime createdAt;
    
    // Constructors
    public JobRoleRotationDto() {}
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public Long getUserId() {
        return userId;
    }
    
    public void setUserId(Long userId) {
        this.userId = userId;
    }
    
    public String getUserFullName() {
        return userFullName;
    }
    
    public void setUserFullName(String userFullName) {
        this.userFullName = userFullName;
    }
    
    public String getEmployeeId() {
        return employeeId;
    }
    
    public void setEmployeeId(String employeeId) {
        this.employeeId = employeeId;
    }
    
    public Long getJobRoleId() {
        return jobRoleId;
    }
    
    public void setJobRoleId(Long jobRoleId) {
        this.jobRoleId = jobRoleId;
    }
    
    public String getRoleCode() {
        return roleCode;
    }
    
    public void setRoleCode(String roleCode) {
        this.roleCode = roleCode;
    }
    
    public String getRoleName() {
        return roleName;
    }
    
    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }
    
    public RoleType getRoleType() {
        return roleType;
    }
    
    public void setRoleType(RoleType roleType) {
        this.roleType = roleType;
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
}