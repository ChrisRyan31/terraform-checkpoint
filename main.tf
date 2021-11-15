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
  vpc_id                  = aws_vpc.vpc-terraform-checkpoint.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraformed-Subnet-checkpoint"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "gateway-terraform-checkpoint" {
  vpc_id = aws_vpc.vpc-terraform-checkpoint.id

  tags = {
    Name = "terraformed-internet-gateway-checkpoint"
  }
}

# Create a route table
resource "aws_route_table" "route-table-terraform-checkpoint" {
  vpc_id = aws_vpc.vpc-terraform-checkpoint.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway-terraform-checkpoint.id
  }

  tags = {
    Name = "terraformed-route-table-checkpoint"
  }
}

# Route table association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-terraform-checkpoint.id
  route_table_id = aws_route_table.route-table-terraform-checkpoint.id
}

# Create security group
resource "aws_security_group" "security-group-terraform-checkpoint" {
  name        = "allow_inbound"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc-terraform-checkpoint.id

  ingress {
    description = "Http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraformed-security-group-checkpoint"
  }
}

# Launch EC2 T2 Micro Instance

resource "aws_instance" "ec2-t2-micro" {
  ami                         = "ami-00be885d550dcee43"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet-terraform-checkpoint.id
  vpc_security_group_ids      = [aws_security_group.security-group-terraform-checkpoint.id]
  user_data                   = file("install.sh")
  tags = {
    Name = "terraformed-ec2-checkpoint"
  }
}

output "ec2-public-ip" {
  value = aws_instance.ec2-t2-micro.public_ip
}
