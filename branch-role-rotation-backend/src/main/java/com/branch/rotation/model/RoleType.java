package com.branch.rotation.model;

public enum RoleType {
    BDO("Branch Development Officer"),
    CSE("Customer Service Executive"),
    BM("Branch Manager");
    
    private final String displayName;
    
    RoleType(String displayName) {
        this.displayName = displayName;
    }
    
    public String getDisplayName() {
        return displayName;
    }
}