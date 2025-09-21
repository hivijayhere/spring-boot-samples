package com.dataarchival.service;

import com.dataarchival.dto.TableConfigDTO;
import com.dataarchival.entity.TableConfig;
import com.dataarchival.repository.TableConfigRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class TableConfigService {
    
    @Autowired
    private TableConfigRepository tableConfigRepository;
    
    public List<TableConfigDTO> getAllTableConfigs() {
        return tableConfigRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    public Optional<TableConfigDTO> getTableConfigById(Long id) {
        return tableConfigRepository.findById(id)
                .map(this::convertToDTO);
    }
    
    public Optional<TableConfigDTO> getTableConfigByTableName(String tableName) {
        return tableConfigRepository.findByTableName(tableName)
                .map(this::convertToDTO);
    }
    
    public TableConfigDTO createTableConfig(TableConfigDTO tableConfigDTO) {
        if (tableConfigRepository.existsByTableName(tableConfigDTO.getTableName())) {
            throw new IllegalArgumentException("Table configuration already exists for: " + tableConfigDTO.getTableName());
        }
        
        TableConfig tableConfig = convertToEntity(tableConfigDTO);
        tableConfig.setIsActive(true);
        TableConfig savedConfig = tableConfigRepository.save(tableConfig);
        return convertToDTO(savedConfig);
    }
    
    public TableConfigDTO updateTableConfig(Long id, TableConfigDTO tableConfigDTO) {
        TableConfig existingConfig = tableConfigRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Table configuration not found with id: " + id));
        
        existingConfig.setArchivalDays(tableConfigDTO.getArchivalDays());
        existingConfig.setPurgeDays(tableConfigDTO.getPurgeDays());
        existingConfig.setIsActive(tableConfigDTO.getIsActive());
        
        TableConfig updatedConfig = tableConfigRepository.save(existingConfig);
        return convertToDTO(updatedConfig);
    }
    
    public void deleteTableConfig(Long id) {
        if (!tableConfigRepository.existsById(id)) {
            throw new IllegalArgumentException("Table configuration not found with id: " + id);
        }
        tableConfigRepository.deleteById(id);
    }
    
    public List<TableConfigDTO> getActiveTableConfigs() {
        return tableConfigRepository.findByIsActiveTrue().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    private TableConfigDTO convertToDTO(TableConfig tableConfig) {
        TableConfigDTO dto = new TableConfigDTO();
        dto.setId(tableConfig.getId());
        dto.setTableName(tableConfig.getTableName());
        dto.setArchivalDays(tableConfig.getArchivalDays());
        dto.setPurgeDays(tableConfig.getPurgeDays());
        dto.setIsActive(tableConfig.getIsActive());
        dto.setCreatedAt(tableConfig.getCreatedAt());
        dto.setUpdatedAt(tableConfig.getUpdatedAt());
        return dto;
    }
    
    private TableConfig convertToEntity(TableConfigDTO dto) {
        TableConfig entity = new TableConfig();
        entity.setId(dto.getId());
        entity.setTableName(dto.getTableName());
        entity.setArchivalDays(dto.getArchivalDays());
        entity.setPurgeDays(dto.getPurgeDays());
        entity.setIsActive(dto.getIsActive());
        return entity;
    }
}