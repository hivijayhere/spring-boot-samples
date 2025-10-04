package com.branch.rotation.repository;

import com.branch.rotation.model.JobRole;
import com.branch.rotation.model.RoleType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface JobRoleRepository extends JpaRepository<JobRole, Long> {
    
    Optional<JobRole> findByRoleCode(String roleCode);
    
    List<JobRole> findByRoleType(RoleType roleType);
    
    List<JobRole> findByIsActive(Boolean isActive);
    
    List<JobRole> findByRoleTypeAndIsActive(RoleType roleType, Boolean isActive);
    
    boolean existsByRoleCode(String roleCode);
}