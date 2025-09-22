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
