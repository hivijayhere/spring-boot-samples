package com.dataarchival.controller;

import com.dataarchival.dto.JobExecutionDTO;
import com.dataarchival.entity.JobExecutionHistory;
import com.dataarchival.service.DataArchivalService;
import com.dataarchival.service.JobExecutionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/v1/data")
@CrossOrigin(origins = "*")
public class DataArchivalController {
    
    @Autowired
    private DataArchivalService dataArchivalService;
    
    @Autowired
    private JobExecutionService jobExecutionService;
    
    @PostMapping("/trigger/archive")
    public ResponseEntity<JobExecutionDTO> triggerArchivalJob(@RequestParam String tableName) {
        try {
            dataArchivalService.executeArchivalJob(tableName);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PostMapping("/trigger/purge")
    public ResponseEntity<JobExecutionDTO> triggerPurgeJob(@RequestParam String tableName) {
        try {
            dataArchivalService.executePurgeJob(tableName);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/preview/archive")
    public ResponseEntity<Map<String, Object>> previewArchivalData(
            @RequestParam String tableName, 
            @RequestParam Integer days) {
        try {
            Map<String, Object> preview = dataArchivalService.previewArchivalData(tableName, days);
            return ResponseEntity.ok(preview);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/preview/purge")
    public ResponseEntity<Map<String, Object>> previewPurgeData(
            @RequestParam String tableName, 
            @RequestParam Integer days) {
        try {
            Map<String, Object> preview = dataArchivalService.previewPurgeData(tableName, days);
            return ResponseEntity.ok(preview);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PostMapping("/rollback")
    public ResponseEntity<Map<String, Object>> rollbackOperation(@RequestParam Long jobId) {
        try {
            // Implementation for rollback would go here
            // This is a placeholder for future enhancement
            return ResponseEntity.ok(Map.of("message", "Rollback functionality not implemented yet"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}