# main.tf
terraform {
  required_providers {
    hcp = {
      source = "hashicorp/hcp"
      version = "0.77.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "5.25.0"
    }
  }
}

provider "hcp" {
}

provider "aws" {
  region = "us-west-2"
}

data "hcp_packer_iteration" "nginx-iteration" {
  bucket_name = "docker-demo"
  channel     = "latest"
}

data "hcp_packer_image" "nginx-image" {
  bucket_name    = "docker-demo"
  iteration_id   = data.hcp_packer_iteration.nginx-iteration.ulid
  cloud_provider = "docker"
  region = "docker"
}

data "aws_default_tags" "default" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1"

  name = "${local.name}-vpc"
  cidr = "10.0.0.0/16"

  azs              = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  vpc_tags = {
    Name = "${local.name}-vpc"
  }

  public_subnet_tags = {
    "network.scope"                                   = "public"
    "kubernetes.io/role/elb"                          = "1"
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "network.scope"                                   = "private"
    "kubernetes.io/role/internal-elb"                 = "1"
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
  }

  database_subnet_tags = {
    "network.scope" = "database"
  }
}