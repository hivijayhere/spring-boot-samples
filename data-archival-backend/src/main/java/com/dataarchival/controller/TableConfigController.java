package com.dataarchival.controller;

import com.dataarchival.dto.TableConfigDTO;
import com.dataarchival.service.TableConfigService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/v1/config/tables")
@CrossOrigin(origins = "*")
public class TableConfigController {
    
    @Autowired
    private TableConfigService tableConfigService;
    
    @GetMapping
    public ResponseEntity<List<TableConfigDTO>> getAllTableConfigs() {
        List<TableConfigDTO> configs = tableConfigService.getAllTableConfigs();
        return ResponseEntity.ok(configs);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<TableConfigDTO> getTableConfigById(@PathVariable Long id) {
        Optional<TableConfigDTO> config = tableConfigService.getTableConfigById(id);
        return config.map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/name/{tableName}")
    public ResponseEntity<TableConfigDTO> getTableConfigByTableName(@PathVariable String tableName) {
        Optional<TableConfigDTO> config = tableConfigService.getTableConfigByTableName(tableName);
        return config.map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
    }
    
    @PostMapping
    public ResponseEntity<TableConfigDTO> createTableConfig(@Valid @RequestBody TableConfigDTO tableConfigDTO) {
        try {
            TableConfigDTO createdConfig = tableConfigService.createTableConfig(tableConfigDTO);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdConfig);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<TableConfigDTO> updateTableConfig(@PathVariable Long id, 
                                                           @Valid @RequestBody TableConfigDTO tableConfigDTO) {
        try {
            TableConfigDTO updatedConfig = tableConfigService.updateTableConfig(id, tableConfigDTO);
            return ResponseEntity.ok(updatedConfig);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTableConfig(@PathVariable Long id) {
        try {
            tableConfigService.deleteTableConfig(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @GetMapping("/active")
    public ResponseEntity<List<TableConfigDTO>> getActiveTableConfigs() {
        List<TableConfigDTO> configs = tableConfigService.getActiveTableConfigs();
        return ResponseEntity.ok(configs);
    }
}