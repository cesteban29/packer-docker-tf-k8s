terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.25.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"  # Replace with your desired AWS region
}

resource "aws_ecr_repository" "docker-demo" {
  name = "docker-demo"  # Replace with your desired repository name
  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.docker-demo.repository_url
}
