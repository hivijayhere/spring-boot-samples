#!/bin/bash

# Data Archival Project Packaging Script
echo "📦 Packaging Data Archival and Purging Admin Application..."

# Create project directory
PROJECT_NAME="data-archival-purging-app"
mkdir -p $PROJECT_NAME

# Copy all project files
echo "📁 Copying project files..."
cp -r data-archival-backend $PROJECT_NAME/
cp -r flutter-admin-app $PROJECT_NAME/
cp -r database-scripts $PROJECT_NAME/
cp *.md $PROJECT_NAME/

# Create a comprehensive setup script
cat > $PROJECT_NAME/setup.sh << 'EOF'
#!/bin/bash

echo "🚀 Setting up Data Archival and Purging Admin Application..."

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check Java
if ! command -v java &> /dev/null; then
    echo "❌ Java is not installed. Please install Java 17 or higher."
    exit 1
fi

# Check MySQL
if ! command -v mysql &> /dev/null; then
    echo "❌ MySQL is not installed. Please install MySQL 8.0 or higher."
    exit 1
fi

# Check Maven
if ! command -v mvn &> /dev/null; then
    echo "❌ Maven is not installed. Please install Maven 3.6 or higher."
    exit 1
fi

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter 3.0 or higher."
    exit 1
fi

echo "✅ All prerequisites found!"

# Setup database
echo "🗄️ Setting up databases..."
mysql -u root -p < database-scripts/01_create_live_database.sql
mysql -u root -p < database-scripts/02_create_archival_database.sql

# Build backend
echo "🔨 Building backend..."
cd data-archival-backend
mvn clean install
cd ..

# Setup Flutter
echo "📱 Setting up Flutter app..."
cd flutter-admin-app
flutter pub get
cd ..

echo "✅ Setup complete!"
echo ""
echo "🚀 To start the application:"
echo "1. Backend: cd data-archival-backend && mvn spring-boot:run"
echo "2. Frontend: cd flutter-admin-app && flutter run -d chrome"
echo ""
echo "📚 Read README.md for detailed instructions"
EOF

chmod +x $PROJECT_NAME/setup.sh

# Create a quick start guide
cat > $PROJECT_NAME/QUICK_START.md << 'EOF'
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
EOF

# Create ZIP file
echo "📦 Creating ZIP file..."
zip -r $PROJECT_NAME.zip $PROJECT_NAME/ -x "*.git*" "node_modules/*" "target/*" "build/*" "*.iml" "*.ipr" "*.iws"

echo "✅ Project packaged successfully!"
echo "📁 Project directory: $PROJECT_NAME/"
echo "📦 ZIP file: $PROJECT_NAME.zip"
echo ""
echo "🚀 To use the project:"
echo "1. Extract the ZIP file"
echo "2. Run: cd $PROJECT_NAME && ./setup.sh"
echo "3. Follow the instructions in QUICK_START.md"