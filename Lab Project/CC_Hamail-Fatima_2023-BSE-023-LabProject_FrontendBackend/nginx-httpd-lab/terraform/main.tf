terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "frontend_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
}

resource "aws_subnet" "backend_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
}

resource "aws_security_group" "frontend_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backend_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "frontend" {
  ami                    = "ami-0c55b159cbfafe1f0" # Replace with a valid AMI ID
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.frontend_subnet.id
  key_name               = var.public_key
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]

  tags = {
    Name = "${var.env_prefix}-frontend"
  }
}

resource "aws_instance" "backend" {
  count                  = 3
  ami                    = "ami-0c55b159cbfafe1f0" # Replace with a valid AMI ID
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.backend_subnet.id
  key_name               = var.public_key
  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  tags = {
    Name = "${var.env_prefix}-backend-${count.index + 1}"
  }
}

output "frontend_public_ip" {
  value = aws_instance.frontend.public_ip
}

output "backend_private_ips" {
  value = aws_instance.backend[*].private_ip
}