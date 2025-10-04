import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  
  // API Configuration
  static const String baseUrl = 'http://10.0.2.2:8080/api';
  static const String authEndpoint = '/auth';
  static const String jobRoleEndpoint = '/job-role-rotation';
  
  // Shared Preferences Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  
  // App Strings
  static const String appName = 'Branch Role Rotation';
  static const String loginTitle = 'Login';
  static const String homeTitle = 'Dashboard';
  static const String myJobRoleTitle = 'My Job Role Details';
  static const String myTeamTitle = 'My Team Job Role Details';
  static const String asOnDateTitle = 'As on Date';
  
  // Role Types
  static const String roleBDO = 'BDO';
  static const String roleCSE = 'CSE';
  static const String roleBM = 'BM';
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String invalidCredentials = 'Invalid username or password.';
  static const String sessionExpired = 'Session expired. Please login again.';
  static const String unknownError = 'An unknown error occurred.';
  
  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String logoutSuccess = 'Logged out successfully!';
  
  // Dimensions
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;
}