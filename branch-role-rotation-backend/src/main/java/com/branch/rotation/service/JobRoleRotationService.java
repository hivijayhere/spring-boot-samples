package com.branch.rotation.service;

import com.branch.rotation.dto.BMViewDto;
import com.branch.rotation.dto.JobRoleRotationDto;
import com.branch.rotation.model.JobRole;
import com.branch.rotation.model.JobRoleRotation;
import com.branch.rotation.model.RoleType;
import com.branch.rotation.model.User;
import com.branch.rotation.repository.JobRoleRepository;
import com.branch.rotation.repository.JobRoleRotationRepository;
import com.branch.rotation.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class JobRoleRotationService {
    
    @Autowired
    private JobRoleRotationRepository jobRoleRotationRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private JobRoleRepository jobRoleRepository;
    
    public List<JobRoleRotationDto> getUserJobRoleHistory(Long userId) {
        List<JobRoleRotation> rotations = jobRoleRotationRepository.findByUserIdOrderByEffectiveFromDesc(userId);
        return rotations.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    public List<JobRoleRotationDto> getUserJobRoleHistoryAsOnDate(Long userId, LocalDate asOnDate) {
        List<JobRoleRotation> rotations = jobRoleRotationRepository.findByUserIdAndAsOnDate(userId, asOnDate);
        return rotations.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    public JobRoleRotationDto getCurrentUserRole(Long userId) {
        JobRoleRotation currentRole = jobRoleRotationRepository.findByUserIdAndIsCurrentTrue(userId)
                .orElse(null);
        return currentRole != null ? convertToDto(currentRole) : null;
    }
    
    public BMViewDto getBMView(Long userId, LocalDate asOnDate) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        // Get BM's own job role details
        List<JobRoleRotationDto> myJobRoleDetails = getUserJobRoleHistoryAsOnDate(userId, asOnDate);
        
        // Get team job role details (BDO/CSE under this BM)
        List<JobRoleRotationDto> myTeamJobRoleDetails = getTeamJobRoleDetailsAsOnDate(user.getBranchCode(), asOnDate);
        
        String asOnDateStr = asOnDate != null ? asOnDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) : 
                           LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        
        return new BMViewDto(myJobRoleDetails, myTeamJobRoleDetails, asOnDateStr);
    }
    
    public List<JobRoleRotationDto> getTeamJobRoleDetailsAsOnDate(String branchCode, LocalDate asOnDate) {
        List<JobRoleRotation> teamRotations = jobRoleRotationRepository.findTeamMembersByBranchCodeAndAsOnDate(branchCode, asOnDate);
        return teamRotations.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    public List<JobRoleRotationDto> getBranchJobRoleHistory(String branchCode) {
        List<JobRoleRotation> rotations = jobRoleRotationRepository.findByBranchCodeOrderByEffectiveFromDesc(branchCode);
        return rotations.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    public List<JobRoleRotationDto> getBranchJobRoleHistoryAsOnDate(String branchCode, LocalDate asOnDate) {
        List<JobRoleRotation> rotations = jobRoleRotationRepository.findByBranchCodeAndAsOnDate(branchCode, asOnDate);
        return rotations.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    public JobRoleRotationDto createJobRoleRotation(Long userId, Long jobRoleId, String branchCode, 
                                                   String branchName, LocalDate effectiveFrom, String createdBy) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        JobRole jobRole = jobRoleRepository.findById(jobRoleId)
                .orElseThrow(() -> new RuntimeException("Job role not found"));
        
        // End current role if exists
        endCurrentRole(userId, effectiveFrom.minusDays(1));
        
        JobRoleRotation rotation = new JobRoleRotation(user, jobRole, branchCode, branchName, effectiveFrom, createdBy);
        rotation.setIsCurrent(true);
        
        JobRoleRotation savedRotation = jobRoleRotationRepository.save(rotation);
        return convertToDto(savedRotation);
    }
    
    private void endCurrentRole(Long userId, LocalDate endDate) {
        JobRoleRotation currentRole = jobRoleRotationRepository.findByUserIdAndIsCurrentTrue(userId)
                .orElse(null);
        
        if (currentRole != null) {
            currentRole.setIsCurrent(false);
            currentRole.setEffectiveTo(endDate);
            jobRoleRotationRepository.save(currentRole);
        }
    }
    
    private JobRoleRotationDto convertToDto(JobRoleRotation rotation) {
        JobRoleRotationDto dto = new JobRoleRotationDto();
        dto.setId(rotation.getId());
        dto.setUserId(rotation.getUser().getId());
        dto.setUserFullName(rotation.getUser().getFullName());
        dto.setEmployeeId(rotation.getUser().getEmployeeId());
        dto.setJobRoleId(rotation.getJobRole().getId());
        dto.setRoleCode(rotation.getJobRole().getRoleCode());
        dto.setRoleName(rotation.getJobRole().getRoleName());
        dto.setRoleType(rotation.getJobRole().getRoleType());
        dto.setBranchCode(rotation.getBranchCode());
        dto.setBranchName(rotation.getBranchName());
        dto.setEffectiveFrom(rotation.getEffectiveFrom());
        dto.setEffectiveTo(rotation.getEffectiveTo());
        dto.setIsCurrent(rotation.getIsCurrent());
        dto.setCreatedBy(rotation.getCreatedBy());
        dto.setCreatedAt(rotation.getCreatedAt());
        return dto;
    }
}