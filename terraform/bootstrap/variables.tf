variable "region" {
  description = "AWS region to create bootstrap resources in"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket to use for Terraform state"
  type        = string
  default     = "wky21-eks-tf-state"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table to use for Terraform locking"
  type        = string
  default     = "tf-locks"
}