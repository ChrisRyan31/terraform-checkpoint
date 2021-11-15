terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

# Create a VPC
resource "aws_vpc" "vpc-terraform-checkpoint" {
  cidr_block = "10.0.0.0/16"
  tags = {
      Name = "terraformed-VPC-checkpoint"
  }
}

# Create a subnet
resource "aws_subnet" "subnet-terraform-checkpoint" {
  vpc_id     = aws_vpc.vpc-terraform-checkpoint.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "terraformed-Subnet-checkpoint"
  }
}