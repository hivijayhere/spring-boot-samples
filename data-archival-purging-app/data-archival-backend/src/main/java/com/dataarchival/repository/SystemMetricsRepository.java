package com.dataarchival.repository;

import com.dataarchival.entity.SystemMetrics;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SystemMetricsRepository extends JpaRepository<SystemMetrics, Long> {
    
    Optional<SystemMetrics> findByTableName(String tableName);
    
    @Query("SELECT SUM(sm.totalRecords) FROM SystemMetrics sm")
    Long getTotalRecordsAcrossAllTables();
    
    @Query("SELECT SUM(sm.archivedRecords) FROM SystemMetrics sm")
    Long getTotalArchivedRecordsAcrossAllTables();
    
    @Query("SELECT SUM(sm.purgedRecords) FROM SystemMetrics sm")
    Long getTotalPurgedRecordsAcrossAllTables();
    
    @Query("SELECT COUNT(sm) FROM SystemMetrics sm")
    Long getTotalTablesCount();
    
    List<SystemMetrics> findAllByOrderByUpdatedAtDesc();
}