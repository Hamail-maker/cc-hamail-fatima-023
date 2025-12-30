# VPC CIDR block
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr_block))
    error_message = "Invalid VPC CIDR block."
  }
}

# Subnet CIDR block
variable "subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.subnet_cidr_block))
    error_message = "Invalid Subnet CIDR block."
  }
}

# Availability Zone
variable "availability_zone" {
  description = "Availability Zone for subnet"
  type        = string
}

# Environment prefix
variable "env_prefix" {
  description = "Environment prefix for resource naming"
  type        = string
  default     = "dev"
}

# EC2 instance type
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# SSH keys
variable "public_key" {
  description = "Path to SSH public key"
  type        = string
}

variable "private_key" {
  description = "Path to SSH private key"
  type        = string
}

# Your public IP for SSH access
variable "my_ip" {
  description = "Your public IP for SSH access"
  type        = string
}
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}


# Backend server configuration
variable "backend_servers" {
  description = "Backend server configuration list"
  type = list(object({
    name        = string
    type        = string          # Added type field for instance type
    script_path = string
  }))
}
