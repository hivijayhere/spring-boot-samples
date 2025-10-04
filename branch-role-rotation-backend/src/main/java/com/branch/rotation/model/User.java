package com.branch.rotation.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "users")
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "employee_id", unique = true, nullable = false)
    @NotBlank
    @Size(max = 50)
    private String employeeId;
    
    @Column(unique = true, nullable = false)
    @NotBlank
    @Size(max = 100)
    private String username;
    
    @Column(unique = true, nullable = false)
    @NotBlank
    @Email
    @Size(max = 255)
    private String email;
    
    @Column(nullable = false)
    @NotBlank
    @Size(max = 255)
    private String password;
    
    @Column(name = "first_name", nullable = false)
    @NotBlank
    @Size(max = 100)
    private String firstName;
    
    @Column(name = "last_name", nullable = false)
    @NotBlank
    @Size(max = 100)
    private String lastName;
    
    @Column(name = "branch_code", nullable = false)
    @NotBlank
    @Size(max = 20)
    private String branchCode;
    
    @Column(name = "branch_name", nullable = false)
    @NotBlank
    @Size(max = 255)
    private String branchName;
    
    @Column(name = "is_active")
    private Boolean isActive = true;
    
    @CreationTimestamp
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<JobRoleRotation> jobRoleRotations;
    
    // Constructors
    public User() {}
    
    public User(String employeeId, String username, String email, String password, 
                String firstName, String lastName, String branchCode, String branchName) {
        this.employeeId = employeeId;
        this.username = username;
        this.email = email;
        this.password = password;
        this.firstName = firstName;
        this.lastName = lastName;
        this.branchCode = branchCode;
        this.branchName = branchName;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getEmployeeId() {
        return employeeId;
    }
    
    public void setEmployeeId(String employeeId) {
        this.employeeId = employeeId;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
    public String getFirstName() {
        return firstName;
    }
    
    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }
    
    public String getLastName() {
        return lastName;
    }
    
    public void setLastName(String lastName) {
        this.lastName = lastName;
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
    
    public List<JobRoleRotation> getJobRoleRotations() {
        return jobRoleRotations;
    }
    
    public void setJobRoleRotations(List<JobRoleRotation> jobRoleRotations) {
        this.jobRoleRotations = jobRoleRotations;
    }
    
    public String getFullName() {
        return firstName + " " + lastName;
    }
}