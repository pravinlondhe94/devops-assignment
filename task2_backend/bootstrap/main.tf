terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region for remote state backend infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform remote state"
  type        = string
  default     = "devops-assignment-tfstate-000000000000"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "devops-assignment-tfstate-locks"
}

# S3 Bucket for Terraform Remote State
resource "aws_s3_bucket" "tf_state" {
  bucket        = var.bucket_name
  force_destroy = false

  tags = {
    Name        = var.bucket_name
    Environment = "Management"
    Owner       = "DevOps"
    Purpose     = "TerraformRemoteState"
  }
}

# Enable Versioning for state recovery and rollbacks
resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-Side Encryption (SSE-AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_encryption" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to state bucket
resource "aws_s3_bucket_public_access_block" "tf_state_pab" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB Table for Distributed State Locking
resource "aws_dynamodb_table" "tf_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = var.dynamodb_table_name
    Environment = "Management"
    Owner       = "DevOps"
    Purpose     = "TerraformStateLocks"
  }
}
