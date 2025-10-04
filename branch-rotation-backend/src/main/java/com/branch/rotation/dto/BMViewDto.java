package com.branch.rotation.dto;

import java.util.List;

public class BMViewDto {
    
    private List<JobRoleRotationDto> myJobRoleDetails;
    private List<JobRoleRotationDto> myTeamJobRoleDetails;
    private String asOnDate;
    
    // Constructors
    public BMViewDto() {}
    
    public BMViewDto(List<JobRoleRotationDto> myJobRoleDetails, 
                     List<JobRoleRotationDto> myTeamJobRoleDetails, 
                     String asOnDate) {
        this.myJobRoleDetails = myJobRoleDetails;
        this.myTeamJobRoleDetails = myTeamJobRoleDetails;
        this.asOnDate = asOnDate;
    }
    
    // Getters and Setters
    public List<JobRoleRotationDto> getMyJobRoleDetails() {
        return myJobRoleDetails;
    }
    
    public void setMyJobRoleDetails(List<JobRoleRotationDto> myJobRoleDetails) {
        this.myJobRoleDetails = myJobRoleDetails;
    }
    
    public List<JobRoleRotationDto> getMyTeamJobRoleDetails() {
        return myTeamJobRoleDetails;
    }
    
    public void setMyTeamJobRoleDetails(List<JobRoleRotationDto> myTeamJobRoleDetails) {
        this.myTeamJobRoleDetails = myTeamJobRoleDetails;
    }
    
    public String getAsOnDate() {
        return asOnDate;
    }
    
    public void setAsOnDate(String asOnDate) {
        this.asOnDate = asOnDate;
    }
}