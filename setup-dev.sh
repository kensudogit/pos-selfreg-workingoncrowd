#!/bin/bash

# POS & Self-Registration System Development Setup Script
# This script sets up the local development environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== POS & Self-Registration System Development Setup ===${NC}"

# Check if running on Windows
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo -e "${YELLOW}Detected Windows environment${NC}"
    IS_WINDOWS=true
else
    IS_WINDOWS=false
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    local missing_deps=()
    
    # Check Java
    if ! command_exists java; then
        missing_deps+=("Java 17")
    else
        JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
        if [ "$JAVA_VERSION" -lt 17 ]; then
            missing_deps+=("Java 17 (found version $JAVA_VERSION)")
        fi
    fi
    
    # Check Node.js
    if ! command_exists node; then
        missing_deps+=("Node.js 18+")
    else
        NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$NODE_VERSION" -lt 18 ]; then
            missing_deps+=("Node.js 18+ (found version $NODE_VERSION)")
        fi
    fi
    
    # Check Docker
    if ! command_exists docker; then
        missing_deps+=("Docker")
    fi
    
    # Check Git
    if ! command_exists git; then
        missing_deps+=("Git")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED}Missing prerequisites:${NC}"
        for dep in "${missing_deps[@]}"; do
            echo -e "${RED}  - $dep${NC}"
        done
        echo -e "${YELLOW}Please install the missing dependencies and run this script again.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}All prerequisites are satisfied.${NC}"
}

# Setup database
setup_database() {
    echo -e "${YELLOW}Setting up database...${NC}"
    
    if [ "$IS_WINDOWS" = true ]; then
        # Windows: Use Docker for PostgreSQL
        docker run --name pos-selfreg-postgres \
            -e POSTGRES_DB=pos_selfreg \
            -e POSTGRES_USER=postgres \
            -e POSTGRES_PASSWORD=password \
            -p 5432:5432 \
            -d postgres:15-alpine
        
        echo -e "${GREEN}PostgreSQL started in Docker container.${NC}"
    else
        # Linux/Mac: Check if PostgreSQL is installed
        if command_exists psql; then
            echo -e "${GREEN}PostgreSQL is already installed.${NC}"
        else
            echo -e "${YELLOW}PostgreSQL not found. Please install PostgreSQL 15+ and run this script again.${NC}"
            exit 1
        fi
    fi
}

# Setup backend
setup_backend() {
    echo -e "${YELLOW}Setting up backend...${NC}"
    
    cd backend
    
    # Create gradle wrapper if it doesn't exist
    if [ ! -f "gradlew" ]; then
        echo "Creating Gradle wrapper..."
        gradle wrapper
    fi
    
    # Build the project
    echo "Building backend..."
    if [ "$IS_WINDOWS" = true ]; then
        ./gradlew.bat build -x test
    else
        ./gradlew build -x test
    fi
    
    cd ..
    
    echo -e "${GREEN}Backend setup completed.${NC}"
}

# Setup frontend
setup_frontend() {
    echo -e "${YELLOW}Setting up frontend...${NC}"
    
    cd frontend
    
    # Install dependencies
    echo "Installing Node.js dependencies..."
    npm install
    
    # Create .env.local file
    if [ ! -f ".env.local" ]; then
        echo "Creating environment file..."
        cat > .env.local << EOF
NEXT_PUBLIC_API_URL=http://localhost:8080/api
NEXT_PUBLIC_APP_NAME=POS & Self-Registration System
EOF
    fi
    
    cd ..
    
    echo -e "${GREEN}Frontend setup completed.${NC}"
}

# Setup mobile development environment
setup_mobile() {
    echo -e "${YELLOW}Setting up mobile development environment...${NC}"
    
    cd mobile
    
    # Check if Android Studio is installed
    if command_exists studio; then
        echo -e "${GREEN}Android Studio is installed.${NC}"
    else
        echo -e "${YELLOW}Android Studio not found. Please install Android Studio for mobile development.${NC}"
    fi
    
    # Create local.properties if it doesn't exist
    if [ ! -f "local.properties" ]; then
        echo "Creating local.properties..."
        cat > local.properties << EOF
sdk.dir=$HOME/Android/Sdk
EOF
    fi
    
    cd ..
    
    echo -e "${GREEN}Mobile setup completed.${NC}"
}

# Create development configuration
create_dev_config() {
    echo -e "${YELLOW}Creating development configuration...${NC}"
    
    # Create .env file for backend
    if [ ! -f "backend/.env" ]; then
        cat > backend/.env << EOF
SPRING_PROFILES_ACTIVE=dev
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/pos_selfreg
SPRING_DATASOURCE_USERNAME=postgres
SPRING_DATASOURCE_PASSWORD=password
JWT_SECRET=dev-secret-key-change-in-production
EOF
    fi
    
    # Create docker-compose override for development
    if [ ! -f "docker-compose.dev.yml" ]; then
        cat > docker-compose.dev.yml << EOF
version: '3.8'

services:
  postgres:
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: pos_selfreg_dev
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_dev_data:/var/lib/postgresql/data

  redis:
    ports:
      - "6379:6379"

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    environment:
      SPRING_PROFILES_ACTIVE: dev
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/pos_selfreg_dev
    volumes:
      - ./backend:/app
      - /app/build
      - /app/.gradle

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    environment:
      NEXT_PUBLIC_API_URL: http://localhost:8080/api
    volumes:
      - ./frontend:/app
      - /app/node_modules

volumes:
  postgres_dev_data:
EOF
    fi
    
    echo -e "${GREEN}Development configuration created.${NC}"
}

# Create useful scripts
create_scripts() {
    echo -e "${YELLOW}Creating development scripts...${NC}"
    
    # Start development environment
    cat > start-dev.sh << 'EOF'
#!/bin/bash
echo "Starting development environment..."
docker-compose -f docker-compose.dev.yml up -d
echo "Development environment started!"
echo "Backend: http://localhost:8080"
echo "Frontend: http://localhost:3000"
echo "Database: localhost:5432"
EOF
    chmod +x start-dev.sh
    
    # Stop development environment
    cat > stop-dev.sh << 'EOF'
#!/bin/bash
echo "Stopping development environment..."
docker-compose -f docker-compose.dev.yml down
echo "Development environment stopped!"
EOF
    chmod +x stop-dev.sh
    
    # Reset database
    cat > reset-db.sh << 'EOF'
#!/bin/bash
echo "Resetting database..."
docker-compose -f docker-compose.dev.yml down -v
docker-compose -f docker-compose.dev.yml up -d postgres
sleep 10
echo "Database reset completed!"
EOF
    chmod +x reset-db.sh
    
    echo -e "${GREEN}Development scripts created.${NC}"
}

# Main setup function
main() {
    check_prerequisites
    setup_database
    setup_backend
    setup_frontend
    setup_mobile
    create_dev_config
    create_scripts
    
    echo -e "${GREEN}=== Development setup completed! ===${NC}"
    echo -e "${BLUE}Next steps:${NC}"
    echo -e "${YELLOW}1. Start the development environment:${NC} ./start-dev.sh"
    echo -e "${YELLOW}2. Access the application:${NC}"
    echo -e "   - Frontend: http://localhost:3000"
    echo -e "   - Backend API: http://localhost:8080/api"
    echo -e "   - Database: localhost:5432"
    echo -e "${YELLOW}3. Default admin credentials:${NC}"
    echo -e "   - Username: admin"
    echo -e "   - Password: admin123"
    echo -e "${YELLOW}4. Stop the environment:${NC} ./stop-dev.sh"
    echo -e "${YELLOW}5. Reset database:${NC} ./reset-db.sh"
}

# Run main function
main "$@" 