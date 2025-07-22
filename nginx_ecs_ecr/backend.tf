#create terraform backend to store state file
terraform {
  backend "s3" {
    #S3
    bucket = "tf-state-devops-ecs"
    key    = "home/oleksandr/Desktop/terraform/terraform.tfstate"
    region = "us-east-1"

    #DynamoDB
    dynamodb_table = "tf-state-lock-ecs"
    encrypt        = true
  }
}