````markdown
# Terraform bootstrap for remote state

This directory contains a small Terraform configuration to provision the S3 bucket and DynamoDB table used for remote Terraform state and locking.

NOTE: Create these bootstrap resources before running `terraform init` in the environment that uses the s3 backend. From the repository root:

```bash
cd terraform/bootstrap
tf init
tf apply -auto-approve
```

After the bootstrap resources are created, you can initialize the test environment which references the S3 backend:

```bash
cd ../environments/test
tf init
```

If you already have a local state file in that environment, make a backup before migrating state:

```bash
cp terraform.tfstate terraform.tfstate.backup
tf init
```
````