terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# S3 bucket to hold Terraform state
resource "aws_s3_bucket" "wky21_eks_tf_state" {
  bucket = var.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle {
    prevent_destroy = false
  }
}

# Block public access to the bucket
resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.wky21_eks_tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table used for Terraform state locking
resource "aws_dynamodb_table" "tf_lock" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket created for Terraform state"
  value       = aws_s3_bucket.wky21_eks_tf_state.id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table used for locking"
  value       = aws_dynamodb_table.tf_lock.name
}