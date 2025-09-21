package com.dataarchival.service;

import com.dataarchival.dto.JobExecutionDTO;
import com.dataarchival.entity.JobExecutionHistory;
import com.dataarchival.repository.JobExecutionHistoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class JobExecutionService {
    
    @Autowired
    private JobExecutionHistoryRepository jobExecutionHistoryRepository;
    
    public JobExecutionDTO createJobExecution(String tableName, JobExecutionHistory.JobType jobType) {
        JobExecutionHistory jobExecution = new JobExecutionHistory();
        jobExecution.setTableName(tableName);
        jobExecution.setJobType(jobType);
        jobExecution.setStatus(JobExecutionHistory.JobStatus.PENDING);
        jobExecution.setStartTime(LocalDateTime.now());
        
        JobExecutionHistory savedJob = jobExecutionHistoryRepository.save(jobExecution);
        return convertToDTO(savedJob);
    }
    
    public JobExecutionDTO updateJobStatus(Long jobId, JobExecutionHistory.JobStatus status) {
        JobExecutionHistory jobExecution = jobExecutionHistoryRepository.findById(jobId)
                .orElseThrow(() -> new IllegalArgumentException("Job execution not found with id: " + jobId));
        
        jobExecution.setStatus(status);
        if (status == JobExecutionHistory.JobStatus.COMPLETED || status == JobExecutionHistory.JobStatus.FAILED) {
            jobExecution.setEndTime(LocalDateTime.now());
        }
        
        JobExecutionHistory updatedJob = jobExecutionHistoryRepository.save(jobExecution);
        return convertToDTO(updatedJob);
    }
    
    public JobExecutionDTO updateJobMetrics(Long jobId, Integer recordsProcessed, Integer recordsArchived, Integer recordsPurged) {
        JobExecutionHistory jobExecution = jobExecutionHistoryRepository.findById(jobId)
                .orElseThrow(() -> new IllegalArgumentException("Job execution not found with id: " + jobId));
        
        jobExecution.setRecordsProcessed(recordsProcessed);
        jobExecution.setRecordsArchived(recordsArchived);
        jobExecution.setRecordsPurged(recordsPurged);
        
        JobExecutionHistory updatedJob = jobExecutionHistoryRepository.save(jobExecution);
        return convertToDTO(updatedJob);
    }
    
    public JobExecutionDTO updateJobError(Long jobId, String errorMessage) {
        JobExecutionHistory jobExecution = jobExecutionHistoryRepository.findById(jobId)
                .orElseThrow(() -> new IllegalArgumentException("Job execution not found with id: " + jobId));
        
        jobExecution.setStatus(JobExecutionHistory.JobStatus.FAILED);
        jobExecution.setErrorMessage(errorMessage);
        jobExecution.setEndTime(LocalDateTime.now());
        
        JobExecutionHistory updatedJob = jobExecutionHistoryRepository.save(jobExecution);
        return convertToDTO(updatedJob);
    }
    
    public List<JobExecutionDTO> getJobExecutionsByTableName(String tableName) {
        return jobExecutionHistoryRepository.findByTableNameOrderByCreatedAtDesc(tableName).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    public Page<JobExecutionDTO> getJobExecutionsByTableName(String tableName, Pageable pageable) {
        return jobExecutionHistoryRepository.findByTableNameOrderByCreatedAtDesc(tableName, pageable)
                .map(this::convertToDTO);
    }
    
    public List<JobExecutionDTO> getJobExecutionsByStatus(JobExecutionHistory.JobStatus status) {
        return jobExecutionHistoryRepository.findByStatus(status).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    public List<JobExecutionDTO> getJobExecutionsByTableNameAndJobType(String tableName, JobExecutionHistory.JobType jobType) {
        return jobExecutionHistoryRepository.findByTableNameAndJobTypeOrderByCreatedAtDesc(tableName, jobType).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    public Long getJobCountByStatus(JobExecutionHistory.JobStatus status) {
        return jobExecutionHistoryRepository.countByStatus(status);
    }
    
    public Long getTotalArchivedRecords() {
        Long total = jobExecutionHistoryRepository.getTotalArchivedRecords();
        return total != null ? total : 0L;
    }
    
    public Long getTotalPurgedRecords() {
        Long total = jobExecutionHistoryRepository.getTotalPurgedRecords();
        return total != null ? total : 0L;
    }
    
    public Optional<JobExecutionDTO> getJobExecutionById(Long id) {
        return jobExecutionHistoryRepository.findById(id)
                .map(this::convertToDTO);
    }
    
    private JobExecutionDTO convertToDTO(JobExecutionHistory jobExecution) {
        JobExecutionDTO dto = new JobExecutionDTO();
        dto.setId(jobExecution.getId());
        dto.setTableName(jobExecution.getTableName());
        dto.setJobType(jobExecution.getJobType().name());
        dto.setStatus(jobExecution.getStatus().name());
        dto.setRecordsProcessed(jobExecution.getRecordsProcessed());
        dto.setRecordsArchived(jobExecution.getRecordsArchived());
        dto.setRecordsPurged(jobExecution.getRecordsPurged());
        dto.setStartTime(jobExecution.getStartTime());
        dto.setEndTime(jobExecution.getEndTime());
        dto.setErrorMessage(jobExecution.getErrorMessage());
        dto.setCreatedAt(jobExecution.getCreatedAt());
        return dto;
    }
}