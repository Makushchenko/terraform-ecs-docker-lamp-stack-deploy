/*-----------------------------S3 BUCKET WITH PUBLIC HTML------------------------------*/

#create s3 bucket
resource "aws_s3_bucket" "terraform-state" {
  bucket = "tf-state-devops-mac"

  #prevent from accidental delete
  lifecycle {
    prevent_destroy = false
  }

  #enable versioning
  versioning {
    enabled = true
  }

  #enable server-side encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}


#create s3 bucket
resource "aws_s3_bucket" "simple-static-web" {
  bucket = "simple-html-1324-oleksandr"

  force_destroy = true

  #prevent from accidental delete
  lifecycle {
    prevent_destroy = false
  }

  #enable static web site
  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  #enable versioning
  versioning {
    enabled = true
  }
}


#create DynamoDB table to use for locking
resource "aws_dynamodb_table" "terraform-locks" {
  hash_key     = "LockID"
  name         = "tf-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
}


#Upload an object
resource "aws_s3_bucket_object" "html_object" {
  bucket       = aws_s3_bucket.simple-static-web.id
  key          = "index.html"
  acl          = "public-read"
  source       = "hello.html"
  content_type = "text/html" # to open as site
}
