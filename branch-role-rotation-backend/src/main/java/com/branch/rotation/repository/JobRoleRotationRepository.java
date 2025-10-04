package com.branch.rotation.repository;

import com.branch.rotation.model.JobRoleRotation;
import com.branch.rotation.model.RoleType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface JobRoleRotationRepository extends JpaRepository<JobRoleRotation, Long> {
    
    List<JobRoleRotation> findByUserId(Long userId);
    
    List<JobRoleRotation> findByUserIdOrderByEffectiveFromDesc(Long userId);
    
    Optional<JobRoleRotation> findByUserIdAndIsCurrentTrue(Long userId);
    
    List<JobRoleRotation> findByBranchCode(String branchCode);
    
    List<JobRoleRotation> findByBranchCodeOrderByEffectiveFromDesc(String branchCode);
    
    @Query("SELECT jr FROM JobRoleRotation jr WHERE jr.user.id = :userId AND " +
           "(:asOnDate IS NULL OR jr.effectiveFrom <= :asOnDate) AND " +
           "(jr.effectiveTo IS NULL OR jr.effectiveTo >= :asOnDate) " +
           "ORDER BY jr.effectiveFrom DESC")
    List<JobRoleRotation> findByUserIdAndAsOnDate(@Param("userId") Long userId, 
                                                  @Param("asOnDate") LocalDate asOnDate);
    
    @Query("SELECT jr FROM JobRoleRotation jr WHERE jr.branchCode = :branchCode AND " +
           "(:asOnDate IS NULL OR jr.effectiveFrom <= :asOnDate) AND " +
           "(jr.effectiveTo IS NULL OR jr.effectiveTo >= :asOnDate) " +
           "ORDER BY jr.effectiveFrom DESC")
    List<JobRoleRotation> findByBranchCodeAndAsOnDate(@Param("branchCode") String branchCode, 
                                                      @Param("asOnDate") LocalDate asOnDate);
    
    @Query("SELECT jr FROM JobRoleRotation jr WHERE jr.branchCode = :branchCode AND " +
           "jr.jobRole.roleType = :roleType AND " +
           "(:asOnDate IS NULL OR jr.effectiveFrom <= :asOnDate) AND " +
           "(jr.effectiveTo IS NULL OR jr.effectiveTo >= :asOnDate) " +
           "ORDER BY jr.effectiveFrom DESC")
    List<JobRoleRotation> findByBranchCodeAndRoleTypeAndAsOnDate(@Param("branchCode") String branchCode, 
                                                                 @Param("roleType") RoleType roleType, 
                                                                 @Param("asOnDate") LocalDate asOnDate);
    
    @Query("SELECT jr FROM JobRoleRotation jr WHERE jr.branchCode = :branchCode AND " +
           "jr.jobRole.roleType IN ('BDO', 'CSE') AND " +
           "(:asOnDate IS NULL OR jr.effectiveFrom <= :asOnDate) AND " +
           "(jr.effectiveTo IS NULL OR jr.effectiveTo >= :asOnDate) " +
           "ORDER BY jr.effectiveFrom DESC")
    List<JobRoleRotation> findTeamMembersByBranchCodeAndAsOnDate(@Param("branchCode") String branchCode, 
                                                                @Param("asOnDate") LocalDate asOnDate);
    
    @Query("SELECT jr FROM JobRoleRotation jr WHERE jr.branchCode = :branchCode AND " +
           "jr.jobRole.roleType = 'BM' AND " +
           "(:asOnDate IS NULL OR jr.effectiveFrom <= :asOnDate) AND " +
           "(jr.effectiveTo IS NULL OR jr.effectiveTo >= :asOnDate) " +
           "ORDER BY jr.effectiveFrom DESC")
    List<JobRoleRotation> findBranchManagerByBranchCodeAndAsOnDate(@Param("branchCode") String branchCode, 
                                                                   @Param("asOnDate") LocalDate asOnDate);
    
    @Query("SELECT COUNT(jr) > 0 FROM JobRoleRotation jr WHERE jr.user.id = :userId AND " +
           "jr.jobRole.roleType = :roleType AND " +
           "(:asOnDate IS NULL OR jr.effectiveFrom <= :asOnDate) AND " +
           "(jr.effectiveTo IS NULL OR jr.effectiveTo >= :asOnDate)")
    boolean hasRoleOnDate(@Param("userId") Long userId, 
                         @Param("roleType") RoleType roleType, 
                         @Param("asOnDate") LocalDate asOnDate);
}