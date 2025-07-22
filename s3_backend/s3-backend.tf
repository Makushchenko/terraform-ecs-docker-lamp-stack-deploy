#create s3 bucket
resource "aws_s3_bucket" "terraform-state" {
  bucket = "tf-state-devops-ecs"

  force_destroy = true

  #prevent from accidental delete
  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name     = "terraform-state"
    "devops" = "ecs"
  }
}

#enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform-state-encryption" {
  bucket = aws_s3_bucket.terraform-state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#enable versioning
resource "aws_s3_bucket_versioning" "terraform-state-version" {
  bucket = aws_s3_bucket.terraform-state.id
  versioning_configuration {
    status = "Enabled"
  }
}

#create DynamoDB table to use for locking
resource "aws_dynamodb_table" "terraform-locks" {
  hash_key     = "LockID"
  name         = "tf-state-lock-ecs"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name     = "terraform-locks"
    "devops" = "ecs"
  }
}