#create terraform backend to store state file
terraform {
  backend "s3" {
    #S3
    bucket = "tf-state-devops-mac"
    key    = "home/oleksandr/Desktop/terraform/s3_with_file/terraform.tfstate"
    region = "us-east-1"

    #DynamoDB
    dynamodb_table = "tf-state-lock"
    encrypt        = true
  }
}