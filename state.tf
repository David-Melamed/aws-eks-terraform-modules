module "terraform_state_backend" {
  enabled = true
  source  = "cloudposse/tfstate-backend/aws"
  version = "1.5.0"

  namespace      = local.environment
  stage          = "main"
  name           = "terraform"
  attributes     = ["state"]
  sse_encryption = "AES256"
  
  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend.tf"
  force_destroy                      = false

  # S3 Bucket configuration
  s3_bucket_name = local.bucket_name

  # DynamoDB Table configuration
  dynamodb_enabled = true
  dynamodb_table_name = local.dynamodb_tfstate_table_name
  deletion_protection_enabled = true

  # Additional tags
  tags = {
    Name        = local.cluster_name
    Environment = local.environment
  }
}