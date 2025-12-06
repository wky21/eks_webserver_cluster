output "bootstrap_s3_bucket" {
  description = "S3 bucket name for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "bootstrap_dynamodb_table" {
  description = "DynamoDB table name for Terraform locking"
  value       = aws_dynamodb_table.terraform_lock.name
}