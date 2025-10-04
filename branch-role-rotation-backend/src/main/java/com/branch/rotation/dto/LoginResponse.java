package com.branch.rotation.dto;

import com.branch.rotation.model.User;

public class LoginResponse {
    
    private String token;
    private String tokenType;
    private User user;
    
    // Constructors
    public LoginResponse() {}
    
    public LoginResponse(String token, String tokenType, User user) {
        this.token = token;
        this.tokenType = tokenType;
        this.user = user;
    }
    
    // Getters and Setters
    public String getToken() {
        return token;
    }
    
    public void setToken(String token) {
        this.token = token;
    }
    
    public String getTokenType() {
        return tokenType;
    }
    
    public void setTokenType(String tokenType) {
        this.tokenType = tokenType;
    }
    
    public User getUser() {
        return user;
    }
    
    public void setUser(User user) {
        this.user = user;
    }
}