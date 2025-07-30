#!/bin/bash

# POS & Self-Registration System Deployment Script
# This script deploys the entire system to AWS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="pos-selfreg"
ENVIRONMENT=${1:-production}
AWS_REGION="ap-northeast-1"

echo -e "${GREEN}Starting deployment of ${PROJECT_NAME} to ${ENVIRONMENT} environment${NC}"

# Check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}AWS CLI is not installed. Please install it first.${NC}"
        exit 1
    fi
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Docker is not installed. Please install it first.${NC}"
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        echo -e "${RED}Terraform is not installed. Please install it first.${NC}"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        echo -e "${RED}AWS credentials are not configured. Please run 'aws configure' first.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}All prerequisites are satisfied.${NC}"
}

# Build Docker images
build_images() {
    echo -e "${YELLOW}Building Docker images...${NC}"
    
    # Build backend image
    echo "Building backend image..."
    cd backend
    docker build -t ${PROJECT_NAME}-backend:latest .
    cd ..
    
    # Build frontend image
    echo "Building frontend image..."
    cd frontend
    docker build -t ${PROJECT_NAME}-frontend:latest .
    cd ..
    
    echo -e "${GREEN}Docker images built successfully.${NC}"
}

# Push images to ECR
push_to_ecr() {
    echo -e "${YELLOW}Pushing images to ECR...${NC}"
    
    # Get AWS account ID
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    
    # Create ECR repositories if they don't exist
    aws ecr create-repository --repository-name ${PROJECT_NAME}-backend --region ${AWS_REGION} || true
    aws ecr create-repository --repository-name ${PROJECT_NAME}-frontend --region ${AWS_REGION} || true
    
    # Login to ECR
    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
    
    # Tag and push backend image
    docker tag ${PROJECT_NAME}-backend:latest ${ECR_REGISTRY}/${PROJECT_NAME}-backend:latest
    docker push ${ECR_REGISTRY}/${PROJECT_NAME}-backend:latest
    
    # Tag and push frontend image
    docker tag ${PROJECT_NAME}-frontend:latest ${ECR_REGISTRY}/${PROJECT_NAME}-frontend:latest
    docker push ${ECR_REGISTRY}/${PROJECT_NAME}-frontend:latest
    
    echo -e "${GREEN}Images pushed to ECR successfully.${NC}"
}

# Deploy infrastructure with Terraform
deploy_infrastructure() {
    echo -e "${YELLOW}Deploying infrastructure with Terraform...${NC}"
    
    cd infrastructure
    
    # Initialize Terraform
    terraform init
    
    # Plan deployment
    terraform plan -var="environment=${ENVIRONMENT}" -out=tfplan
    
    # Apply deployment
    terraform apply tfplan
    
    cd ..
    
    echo -e "${GREEN}Infrastructure deployed successfully.${NC}"
}

# Deploy applications
deploy_applications() {
    echo -e "${YELLOW}Deploying applications...${NC}"
    
    # Update ECS services
    aws ecs update-service --cluster ${PROJECT_NAME}-cluster --service ${PROJECT_NAME}-backend --force-new-deployment --region ${AWS_REGION}
    aws ecs update-service --cluster ${PROJECT_NAME}-cluster --service ${PROJECT_NAME}-frontend --force-new-deployment --region ${AWS_REGION}
    
    echo -e "${GREEN}Applications deployed successfully.${NC}"
}

# Run tests
run_tests() {
    echo -e "${YELLOW}Running tests...${NC}"
    
    # Backend tests
    cd backend
    ./gradlew test
    cd ..
    
    # Frontend tests
    cd frontend
    npm test
    cd ..
    
    echo -e "${GREEN}All tests passed.${NC}"
}

# Main deployment flow
main() {
    echo -e "${GREEN}=== POS & Self-Registration System Deployment ===${NC}"
    
    check_prerequisites
    run_tests
    build_images
    push_to_ecr
    deploy_infrastructure
    deploy_applications
    
    echo -e "${GREEN}=== Deployment completed successfully! ===${NC}"
    echo -e "${YELLOW}Application URL: https://${PROJECT_NAME}.example.com${NC}"
    echo -e "${YELLOW}API URL: https://api.${PROJECT_NAME}.example.com${NC}"
}

# Run main function
main "$@" 