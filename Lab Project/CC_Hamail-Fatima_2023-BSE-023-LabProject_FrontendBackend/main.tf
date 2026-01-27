terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env_prefix}-public-subnet"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.env_prefix}-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "main" {
  name        = "${var.env_prefix}-sg"
  description = "Security group for nginx-ha project"
  vpc_id      = aws_vpc.main.id

  # SSH access from local IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

# Key Pair for SSH
resource "aws_key_pair" "deployer" {
  key_name   = "${var.env_prefix}-key"
  public_key = file(pathexpand(var.public_key_path))

  tags = {
    Name = "${var.env_prefix}-key"
  }
}

# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Frontend EC2 Instance (Nginx)
resource "aws_instance" "frontend" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = aws_key_pair.deployer.key_name

  monitoring                  = var.enable_detailed_monitoring
  associate_public_ip_address = true

  tags = {
    Name = "${var.env_prefix}-frontend"
  }

  depends_on = [
    aws_internet_gateway.main
  ]
}

# Backend EC2 Instances (HTTPD)
resource "aws_instance" "backend" {
  count                  = 3
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = aws_key_pair.deployer.key_name

  monitoring                  = var.enable_detailed_monitoring
  associate_public_ip_address = true

  tags = {
    Name = "${var.env_prefix}-backend-${count.index}"
  }

  depends_on = [
    aws_internet_gateway.main
  ]
}

# Generate inventory file for Ansible
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/ansible/inventory/hosts"
  content = templatefile("${path.module}/ansible/inventory/hosts.tpl", {
    frontend_ip      = aws_instance.frontend.public_ip
    backend_ips      = [for b in aws_instance.backend : b.public_ip]
    backend_private_ips = [for b in aws_instance.backend : b.private_ip]
  })

  depends_on = [
    aws_instance.frontend,
    aws_instance.backend
  ]
}

# Null resource to trigger Ansible playbook
resource "null_resource" "ansible_provisioner" {
  triggers = {
    frontend_id  = aws_instance.frontend.id
    backend_ids  = join(",", [for b in aws_instance.backend : b.id])
    inventory_md5 = md5(local_file.ansible_inventory.content)
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for instances to be ready..."
      sleep 30
      
      echo "Running Ansible playbooks..."
      cd ${path.module}/ansible
      
      ANSIBLE_HOST_KEY_CHECKING=False \
      ansible-playbook \
        -i inventory/hosts \
        -u ec2-user \
        --private-key ${pathexpand(var.private_key_path)} \
        playbooks/site.yaml
    EOT
  }

  depends_on = [
    local_file.ansible_inventory
  ]
}
