terraform {
  backend "s3" {
    bucket         = "wky21-eks-tf-state"
    key            = "terraform/environments/test/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-lock-table"
    encrypt        = true
  }
}