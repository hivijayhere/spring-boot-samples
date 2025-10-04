# Branch Role Rotation Mobile App

A Flutter mobile application for managing branch-level job role rotations within banking organizations.

## Features

- **Authentication**: Secure login with JWT tokens
- **Role-based Views**: Different views for BM, BDO, and CSE roles
- **Job Role History**: Complete history of role rotations
- **As on Date Display**: View role data for specific dates
- **BM-Level View**: 
  - My Job Role Details (BM's own role history)
  - My Team Job Role Details (BDO/CSE under the BM)
- **Real-time Data**: Refresh data from backend API
- **Responsive UI**: Modern Material Design interface

## Architecture

- **State Management**: Provider pattern
- **API Integration**: RESTful API calls with HTTP client
- **Local Storage**: SharedPreferences for token and user data
- **Error Handling**: Comprehensive error handling and user feedback

## Screens

1. **Splash Screen**: App initialization and authentication check
2. **Login Screen**: User authentication with demo credentials
3. **Home Screen**: Main dashboard with tabbed interface
   - My Role Tab: Personal job role history and current role
   - Team Tab: Team members' job role details
   - Branch Tab: Complete branch job role history

## Demo Credentials

- **Branch Manager**: Username: `bm001`, Password: `password`
- **Branch Development Officer**: Username: `bdo001`, Password: `password`
- **Customer Service Executive**: Username: `cse001`, Password: `password`

## Setup Instructions

1. Install Flutter SDK
2. Run `flutter pub get` to install dependencies
3. Ensure the Spring Boot backend is running on `http://localhost:8080`
4. Update the API base URL in `lib/utils/app_constants.dart` if needed
5. Run `flutter run` to start the application

## Dependencies

- `provider`: State management
- `http`: API communication
- `shared_preferences`: Local storage
- `intl`: Date formatting
- `json_annotation`: JSON serialization
- `flutter_spinkit`: Loading indicators
- `fluttertoast`: Toast messages

## API Endpoints

The app communicates with the following backend endpoints:

- `POST /api/auth/login` - User authentication
- `POST /api/auth/validate` - Token validation
- `GET /api/job-role-rotation/my-history` - Personal job role history
- `GET /api/job-role-rotation/my-current-role` - Current role
- `GET /api/job-role-rotation/bm-view` - BM-level view
- `GET /api/job-role-rotation/team-history` - Team job role history
- `GET /api/job-role-rotation/branch-history` - Branch job role history

## Widgets

- **DatePickerWidget**: Date selection for "As on Date" functionality
- **JobRoleCard**: Displays job role information with role type badges
- **BMViewWidget**: Specialized view for Branch Manager role

## Error Handling

- Network error handling
- Authentication error handling
- Server error handling
- User-friendly error messages

## Security

- JWT token-based authentication
- Secure token storage
- Automatic token validation
- Session management