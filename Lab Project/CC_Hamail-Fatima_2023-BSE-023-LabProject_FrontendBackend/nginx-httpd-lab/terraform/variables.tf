variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "The CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "The availability zone for the resources"
  type        = string
  default     = "us-east-1a"
}

variable "env_prefix" {
  description = "Prefix for the environment"
  type        = string
  default     = "nginx-httpd"
}

variable "instance_type" {
  description = "The type of EC2 instance to use"
  type        = string
  default     = "t2.micro"
}

variable "public_key" {
  description = "The public key for SSH access"
  type        = string
}

variable "private_key" {
  description = "The private key for SSH access"
  type        = string
}