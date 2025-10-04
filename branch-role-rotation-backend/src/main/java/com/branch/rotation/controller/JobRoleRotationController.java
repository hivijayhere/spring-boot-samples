package com.branch.rotation.controller;

import com.branch.rotation.dto.BMViewDto;
import com.branch.rotation.dto.JobRoleRotationDto;
import com.branch.rotation.model.User;
import com.branch.rotation.service.JobRoleRotationService;
import com.branch.rotation.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/job-role-rotation")
@CrossOrigin(origins = "*")
public class JobRoleRotationController {
    
    @Autowired
    private JobRoleRotationService jobRoleRotationService;
    
    @Autowired
    private UserService userService;
    
    @GetMapping("/my-history")
    public ResponseEntity<?> getMyJobRoleHistory(Authentication authentication) {
        try {
            User user = userService.findByUsername(authentication.getName())
                    .orElseThrow(() -> new RuntimeException("User not found"));
            
            List<JobRoleRotationDto> history = jobRoleRotationService.getUserJobRoleHistory(user.getId());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", history);
            response.put("user", user);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    @GetMapping("/my-history/as-on-date")
    public ResponseEntity<?> getMyJobRoleHistoryAsOnDate(
            Authentication authentication,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate asOnDate) {
        try {
            User user = userService.findByUsername(authentication.getName())
                    .orElseThrow(() -> new RuntimeException("User not found"));
            
            List<JobRoleRotationDto> history = jobRoleRotationService.getUserJobRoleHistoryAsOnDate(user.getId(), asOnDate);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", history);
            response.put("user", user);
            response.put("asOnDate", asOnDate != null ? asOnDate.toString() : LocalDate.now().toString());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    @GetMapping("/my-current-role")
    public ResponseEntity<?> getMyCurrentRole(Authentication authentication) {
        try {
            User user = userService.findByUsername(authentication.getName())
                    .orElseThrow(() -> new RuntimeException("User not found"));
            
            JobRoleRotationDto currentRole = jobRoleRotationService.getCurrentUserRole(user.getId());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", currentRole);
            response.put("user", user);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    @GetMapping("/bm-view")
    public ResponseEntity<?> getBMView(
            Authentication authentication,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate asOnDate) {
        try {
            User user = userService.findByUsername(authentication.getName())
                    .orElseThrow(() -> new RuntimeException("User not found"));
            
            BMViewDto bmView = jobRoleRotationService.getBMView(user.getId(), asOnDate);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", bmView);
            response.put("user", user);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    @GetMapping("/team-history")
    public ResponseEntity<?> getTeamJobRoleHistory(
            Authentication authentication,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate asOnDate) {
        try {
            User user = userService.findByUsername(authentication.getName())
                    .orElseThrow(() -> new RuntimeException("User not found"));
            
            List<JobRoleRotationDto> teamHistory = jobRoleRotationService.getTeamJobRoleDetailsAsOnDate(user.getBranchCode(), asOnDate);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", teamHistory);
            response.put("user", user);
            response.put("asOnDate", asOnDate != null ? asOnDate.toString() : LocalDate.now().toString());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    @GetMapping("/branch-history")
    public ResponseEntity<?> getBranchJobRoleHistory(
            Authentication authentication,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate asOnDate) {
        try {
            User user = userService.findByUsername(authentication.getName())
                    .orElseThrow(() -> new RuntimeException("User not found"));
            
            List<JobRoleRotationDto> branchHistory = jobRoleRotationService.getBranchJobRoleHistoryAsOnDate(user.getBranchCode(), asOnDate);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", branchHistory);
            response.put("user", user);
            response.put("asOnDate", asOnDate != null ? asOnDate.toString() : LocalDate.now().toString());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
}