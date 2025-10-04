package com.branch.rotation.repository;

import com.branch.rotation.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    Optional<User> findByUsername(String username);
    
    Optional<User> findByEmail(String email);
    
    Optional<User> findByEmployeeId(String employeeId);
    
    List<User> findByBranchCode(String branchCode);
    
    List<User> findByBranchCodeAndIsActive(String branchCode, Boolean isActive);
    
    @Query("SELECT u FROM User u WHERE u.branchCode = :branchCode AND u.id IN " +
           "(SELECT DISTINCT jr.user.id FROM JobRoleRotation jr WHERE jr.jobRole.roleType = 'BM')")
    List<User> findBranchManagersByBranchCode(@Param("branchCode") String branchCode);
    
    @Query("SELECT u FROM User u WHERE u.branchCode = :branchCode AND u.id IN " +
           "(SELECT DISTINCT jr.user.id FROM JobRoleRotation jr WHERE jr.jobRole.roleType IN ('BDO', 'CSE'))")
    List<User> findTeamMembersByBranchCode(@Param("branchCode") String branchCode);
    
    boolean existsByUsername(String username);
    
    boolean existsByEmail(String email);
    
    boolean existsByEmployeeId(String employeeId);
}