variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "pos_selfreg"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "backend_image" {
  description = "Backend Docker image"
  type        = string
  default     = "pos-selfreg-backend:latest"
}

variable "backend_count" {
  description = "Number of backend instances"
  type        = number
  default     = 2
}

variable "backend_cpu" {
  description = "Backend CPU units"
  type        = number
  default     = 256
}

variable "backend_memory" {
  description = "Backend memory (MB)"
  type        = number
  default     = 512
}

variable "s3_bucket_name" {
  description = "S3 bucket name for storage"
  type        = string
  default     = "pos-selfreg-storage"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "pos-selfreg.example.com"
}

variable "stripe_secret_key" {
  description = "Stripe secret key"
  type        = string
  sensitive   = true
}

variable "stripe_publishable_key" {
  description = "Stripe publishable key"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT secret key"
  type        = string
  sensitive   = true
} 