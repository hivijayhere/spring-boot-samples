package com.dataarchival.repository;

import com.dataarchival.entity.TableConfig;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TableConfigRepository extends JpaRepository<TableConfig, Long> {
    
    Optional<TableConfig> findByTableName(String tableName);
    
    List<TableConfig> findByIsActiveTrue();
    
    @Query("SELECT tc FROM TableConfig tc WHERE tc.isActive = true AND tc.archivalDays > 0")
    List<TableConfig> findActiveTablesForArchival();
    
    @Query("SELECT tc FROM TableConfig tc WHERE tc.isActive = true AND tc.purgeDays > 0")
    List<TableConfig> findActiveTablesForPurge();
    
    boolean existsByTableName(String tableName);
}