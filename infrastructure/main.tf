terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = "pos-selfreg-terraform-state"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "pos-selfreg"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# VPC and Networking
module "vpc" {
  source = "./modules/vpc"
  
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  azs         = var.availability_zones
}

# RDS Database
module "rds" {
  source = "./modules/rds"
  
  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  db_name         = var.db_name
  db_username     = var.db_username
  db_password     = var.db_password
  db_instance_class = var.db_instance_class
}

# ECS Cluster for Backend
module "ecs_backend" {
  source = "./modules/ecs"
  
  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  app_name        = "pos-selfreg-backend"
  app_port        = 8080
  app_image       = var.backend_image
  app_count       = var.backend_count
  cpu             = var.backend_cpu
  memory          = var.backend_memory
}

# S3 Bucket for Storage
module "s3" {
  source = "./modules/s3"
  
  environment = var.environment
  bucket_name = var.s3_bucket_name
}

# CloudFront for Frontend
module "cloudfront" {
  source = "./modules/cloudfront"
  
  environment = var.environment
  domain_name = var.domain_name
  s3_bucket_id = module.s3.bucket_id
}

# API Gateway
module "api_gateway" {
  source = "./modules/api_gateway"
  
  environment = var.environment
  domain_name = var.domain_name
  ecs_service_name = module.ecs_backend.service_name
  ecs_cluster_name = module.ecs_backend.cluster_name
}

# Lambda Functions
module "lambda" {
  source = "./modules/lambda"
  
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}

# SQS Queue
module "sqs" {
  source = "./modules/sqs"
  
  environment = var.environment
  queue_name  = "pos-selfreg-queue"
}

# CloudWatch Logs
module "cloudwatch" {
  source = "./modules/cloudwatch"
  
  environment = var.environment
  app_name    = "pos-selfreg"
}

# IAM Roles and Policies
module "iam" {
  source = "./modules/iam"
  
  environment = var.environment
  s3_bucket_arn = module.s3.bucket_arn
  sqs_queue_arn = module.sqs.queue_arn
}

# Route53 DNS
module "route53" {
  source = "./modules/route53"
  
  environment = var.environment
  domain_name = var.domain_name
  cloudfront_distribution_id = module.cloudfront.distribution_id
  api_gateway_domain_name = module.api_gateway.domain_name
}

# Certificate Manager
module "acm" {
  source = "./modules/acm"
  
  domain_name = var.domain_name
  environment = var.environment
} 