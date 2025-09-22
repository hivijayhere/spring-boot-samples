package com.dataarchival.service;

import com.dataarchival.entity.TableConfig;
import com.dataarchival.repository.TableConfigRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;

@Service
@Transactional
public class ArchivalSchedulerService {
    
    @Autowired
    private TableConfigRepository tableConfigRepository;
    
    @Autowired
    private DataArchivalService dataArchivalService;
    
    // Run at 12:00 AM IST daily
    @Scheduled(cron = "0 0 0 * * ?", zone = "Asia/Kolkata")
    public void executeScheduledArchivalJobs() {
        System.out.println("Starting scheduled archival jobs at: " + LocalDateTime.now(ZoneId.of("Asia/Kolkata")));
        
        try {
            // Get all active tables configured for archival
            List<TableConfig> tablesForArchival = tableConfigRepository.findActiveTablesForArchival();
            
            for (TableConfig tableConfig : tablesForArchival) {
                try {
                    System.out.println("Executing archival job for table: " + tableConfig.getTableName());
                    dataArchivalService.executeArchivalJob(tableConfig.getTableName());
                    System.out.println("Archival job completed for table: " + tableConfig.getTableName());
                } catch (Exception e) {
                    System.err.println("Archival job failed for table: " + tableConfig.getTableName() + 
                                     " - Error: " + e.getMessage());
                }
            }
            
            // Get all active tables configured for purging
            List<TableConfig> tablesForPurge = tableConfigRepository.findActiveTablesForPurge();
            
            for (TableConfig tableConfig : tablesForPurge) {
                try {
                    System.out.println("Executing purge job for table: " + tableConfig.getTableName());
                    dataArchivalService.executePurgeJob(tableConfig.getTableName());
                    System.out.println("Purge job completed for table: " + tableConfig.getTableName());
                } catch (Exception e) {
                    System.err.println("Purge job failed for table: " + tableConfig.getTableName() + 
                                     " - Error: " + e.getMessage());
                }
            }
            
            System.out.println("Scheduled archival and purge jobs completed at: " + LocalDateTime.now(ZoneId.of("Asia/Kolkata")));
            
        } catch (Exception e) {
            System.err.println("Scheduled job execution failed: " + e.getMessage());
        }
    }
    
    // Manual trigger for archival jobs
    public void triggerArchivalJobs() {
        executeScheduledArchivalJobs();
    }
    
    // Manual trigger for purge jobs only
    public void triggerPurgeJobs() {
        System.out.println("Starting manual purge jobs at: " + LocalDateTime.now(ZoneId.of("Asia/Kolkata")));
        
        try {
            List<TableConfig> tablesForPurge = tableConfigRepository.findActiveTablesForPurge();
            
            for (TableConfig tableConfig : tablesForPurge) {
                try {
                    System.out.println("Executing purge job for table: " + tableConfig.getTableName());
                    dataArchivalService.executePurgeJob(tableConfig.getTableName());
                    System.out.println("Purge job completed for table: " + tableConfig.getTableName());
                } catch (Exception e) {
                    System.err.println("Purge job failed for table: " + tableConfig.getTableName() + 
                                     " - Error: " + e.getMessage());
                }
            }
            
            System.out.println("Manual purge jobs completed at: " + LocalDateTime.now(ZoneId.of("Asia/Kolkata")));
            
        } catch (Exception e) {
            System.err.println("Manual purge job execution failed: " + e.getMessage());
        }
    }
}