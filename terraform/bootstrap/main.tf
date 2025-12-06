# =========================================================
# Terraform Configuration & AWS Provider
# =========================================================


provider "aws" {
  region = "us-east-1"  
}

# =========================================================
# S3 Bucket for Terraform State
# =========================================================
resource "aws_s3_bucket" "terraform_state" {
  bucket = "wky21-eks-tf-state"
  force_destroy = false  

  lifecycle {
    prevent_destroy = true
  }
}

# =========================================================
# S3 Bucket Versioning
# =========================================================
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# =========================================================
# Block Public Access
# =========================================================
resource "aws_s3_bucket_public_access_block" "terraform_state_block" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =========================================================
# DynamoDB Table for Terraform Locking
# =========================================================
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "tf-lock-table"  # Replace with variable if needed
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = "dev"
  }
}

# =========================================================
# Optional Outputs
# =========================================================
output "s3_bucket_id" {
  value       = aws_s3_bucket.terraform_state.id
  description = "S3 bucket ID used for Terraform state"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_lock.name
  description = "DynamoDB table name used for Terraform locking"
}
