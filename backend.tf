resource "aws_dynamodb_table" "basic-dynamodb-table" {
    name           = local.dynamodb_tfstate_table_name
    billing_mode   = "PAY_PER_REQUEST"
    hash_key       = "LockID"   
    attribute {
      name = "LockID"
      type = "S"
    }   
    tags = {
      Name = local.cluster_name
      Environment = local.environment
    }   
    
    # lifecycle {
    #   prevent_destroy = true
    # }
}


resource "aws_s3_bucket" "terraform_state" {
    bucket = local.bucket_name
    object_lock_enabled = false
    
    tags = {
        Name = local.cluster_name
        Environment = local.environment
    }
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_bucket_server_side_encryption" {
    bucket = aws_s3_bucket.terraform_state.id   
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
}

