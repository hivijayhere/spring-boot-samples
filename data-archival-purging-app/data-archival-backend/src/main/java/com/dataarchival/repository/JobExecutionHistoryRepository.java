package com.dataarchival.repository;

import com.dataarchival.entity.JobExecutionHistory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface JobExecutionHistoryRepository extends JpaRepository<JobExecutionHistory, Long> {
    
    List<JobExecutionHistory> findByTableNameOrderByCreatedAtDesc(String tableName);
    
    Page<JobExecutionHistory> findByTableNameOrderByCreatedAtDesc(String tableName, Pageable pageable);
    
    List<JobExecutionHistory> findByStatus(JobExecutionHistory.JobStatus status);
    
    @Query("SELECT jeh FROM JobExecutionHistory jeh WHERE jeh.tableName = :tableName AND jeh.jobType = :jobType ORDER BY jeh.createdAt DESC")
    List<JobExecutionHistory> findByTableNameAndJobTypeOrderByCreatedAtDesc(@Param("tableName") String tableName, 
                                                                           @Param("jobType") JobExecutionHistory.JobType jobType);
    
    @Query("SELECT COUNT(jeh) FROM JobExecutionHistory jeh WHERE jeh.status = :status")
    Long countByStatus(@Param("status") JobExecutionHistory.JobStatus status);
    
    @Query("SELECT COUNT(jeh) FROM JobExecutionHistory jeh WHERE jeh.status = :status AND jeh.createdAt >= :startDate")
    Long countByStatusAndCreatedAtAfter(@Param("status") JobExecutionHistory.JobStatus status, 
                                       @Param("startDate") LocalDateTime startDate);
    
    @Query("SELECT SUM(jeh.recordsArchived) FROM JobExecutionHistory jeh WHERE jeh.jobType = 'ARCHIVE' AND jeh.status = 'COMPLETED'")
    Long getTotalArchivedRecords();
    
    @Query("SELECT SUM(jeh.recordsPurged) FROM JobExecutionHistory jeh WHERE jeh.jobType = 'PURGE' AND jeh.status = 'COMPLETED'")
    Long getTotalPurgedRecords();
}