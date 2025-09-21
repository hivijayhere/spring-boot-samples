# Quick Start Guide

## Prerequisites
- Java 17+
- MySQL 8.0+
- Maven 3.6+
- Flutter 3.0+

## Setup
1. Run the setup script: `./setup.sh`
2. Update database credentials in `data-archival-backend/src/main/resources/application.yml`
3. Update API URL in `flutter-admin-app/lib/services/api_service.dart`

## Start Application
1. Start backend: `cd data-archival-backend && mvn spring-boot:run`
2. Start frontend: `cd flutter-admin-app && flutter run -d chrome`

## Access
- Backend API: http://localhost:8080/api
- Frontend: http://localhost:3000 (Flutter web)

## Documentation
- README.md - Complete setup guide
- DEPLOYMENT_GUIDE.md - Production deployment
- Data_Archival_Purging_Technical_Spec.md - Technical specification
