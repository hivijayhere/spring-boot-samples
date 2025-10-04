# Branch Role Rotation Management System

A comprehensive mobile application system for managing branch-level job role rotations within banking organizations. This system consists of a Spring Boot backend with MySQL database and a Flutter mobile frontend.

## System Overview

The Branch Role Rotation system is designed specifically for branch-level roles (BDO, CSE, and BM) and provides:

- **Complete Role History**: Maintains full history of job role rotations per user
- **Branch-Level Focus**: Only displays role data for branch business roles
- **BM-Level Views**: Specialized views for Branch Managers
- **As on Date Functionality**: View role data for specific historical dates
- **Real-time Updates**: PJMCL handles job role updates captured in the Job Role Rotation table

## Architecture

### Backend (Spring Boot + MySQL)
- **Location**: `/branch-role-rotation-backend/`
- **Technology Stack**: Spring Boot 3.2.0, Spring Security, JPA/Hibernate, MySQL 8.0
- **Authentication**: JWT-based authentication
- **API**: RESTful APIs with comprehensive error handling

### Frontend (Flutter)
- **Location**: `/branch-role-rotation-flutter/`
- **Technology Stack**: Flutter 3.0+, Provider state management
- **UI**: Material Design with responsive layouts
- **Features**: Role-based views, date picker, real-time data refresh

## Key Features

### 1. Role-Based Access
- **Branch Manager (BM)**: Full access to own role history and team member roles
- **Branch Development Officer (BDO)**: Access to own role history
- **Customer Service Executive (CSE)**: Access to own role history

### 2. BM-Level View Components
- **My Job Role Details**: Shows BM's own job role rotation history and current role
- **My Team Job Role Details**: Displays job role rotation history for team members (BDO/CSE) under the BM

### 3. As on Date Widget
- Date picker functionality to view role data for specific historical dates
- Maintains complete historical records
- Only displays data if historical records exist in the table

### 4. Data Management
- Complete history of job roles per user
- Branch repository changes while maintaining common base roles
- PJMCL-managed job role updates
- No roll-up or visibility for non-branch business unit users

## Database Schema

### Core Tables
1. **users**: User information and branch details
2. **job_roles**: Available job roles (BDO, CSE, BM)
3. **job_role_rotations**: Complete history of role rotations

### Key Relationships
- Users belong to branches
- Job role rotations link users to roles with effective dates
- Historical data maintained with complete audit trail

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/validate` - Token validation

### Job Role Management
- `GET /api/job-role-rotation/my-history` - Personal job role history
- `GET /api/job-role-rotation/my-history/as-on-date` - History for specific date
- `GET /api/job-role-rotation/my-current-role` - Current active role
- `GET /api/job-role-rotation/bm-view` - BM-level comprehensive view
- `GET /api/job-role-rotation/team-history` - Team member role history
- `GET /api/job-role-rotation/branch-history` - Complete branch role history

## Setup Instructions

### Prerequisites
- Java 17+
- MySQL 8.0+
- Flutter SDK 3.0+
- Maven 3.6+

### Backend Setup
1. Navigate to `/branch-role-rotation-backend/`
2. Update `application.yml` with your MySQL credentials
3. Run the SQL schema script to create database and tables
4. Execute: `mvn spring-boot:run`
5. Backend will be available at `http://localhost:8080`

### Frontend Setup
1. Navigate to `/branch-role-rotation-flutter/`
2. Run: `flutter pub get`
3. Update API base URL in `lib/utils/app_constants.dart` if needed
4. Run: `flutter run`

### Database Setup
1. Create MySQL database: `branch_role_rotation`
2. Run the schema script to create tables and insert sample data
3. Default credentials are included in the schema

## Demo Credentials

- **Branch Manager**: Username: `bm001`, Password: `password`
- **Branch Development Officer**: Username: `bdo001`, Password: `password`
- **Customer Service Executive**: Username: `cse001`, Password: `password`

## Security Features

- JWT token-based authentication
- Password encryption with BCrypt
- Role-based access control
- Secure API endpoints
- Token validation and refresh

## Mobile App Features

### Screens
1. **Splash Screen**: App initialization and authentication check
2. **Login Screen**: Secure authentication with demo credentials
3. **Home Screen**: Tabbed interface with role-specific views

### Widgets
- **DatePickerWidget**: As on Date functionality
- **JobRoleCard**: Role information display with badges
- **BMViewWidget**: Specialized Branch Manager view

### State Management
- Provider pattern for state management
- API service layer for backend communication
- Local storage for authentication tokens
- Error handling and user feedback

## Business Rules

1. **Branch-Level Only**: System is applicable only for branch-level roles (BDO, CSE, BM)
2. **Historical Data**: Only display role data if historical records exist
3. **PJMCL Management**: PJMCL handles job role updates
4. **Complete History**: Maintain complete history of job roles per user
5. **Branch Repository**: Branch repository may change, but base role remains common
6. **No Roll-up**: No roll-up or visibility for non-branch business unit users

## Testing

### Backend Testing
- Unit tests for services and repositories
- Integration tests for API endpoints
- Security tests for authentication

### Frontend Testing
- Widget tests for UI components
- Integration tests for API communication
- User flow testing for different roles

## Deployment

### Backend Deployment
- Spring Boot JAR deployment
- MySQL database configuration
- Environment-specific configuration

### Frontend Deployment
- Flutter APK/IPA generation
- App store deployment
- Configuration for production API endpoints

## Future Enhancements

- Push notifications for role changes
- Offline data synchronization
- Advanced reporting and analytics
- Role change approval workflows
- Integration with HR systems

## Support

For technical support or questions about the Branch Role Rotation system, please refer to the individual README files in the backend and frontend directories.