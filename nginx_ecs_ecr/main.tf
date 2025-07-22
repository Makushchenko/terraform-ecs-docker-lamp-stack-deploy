terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "2.16.0"
    }
  }
}


# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}


# connect to provider
provider "docker" {
  host = "unix:///var/run/docker.sock"
}
