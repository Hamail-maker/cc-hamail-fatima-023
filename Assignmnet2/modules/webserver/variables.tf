variable "env_prefix" {
  description = "Environment prefix (e.g., dev, prod)"
  type        = string
}

variable "instance_name" {
  description = "Base name of the instance"
  type        = string
}

variable "instance_suffix" {
  description = "Suffix for instance naming"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone for the instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where instance will be launched"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the instance"
  type        = string
}

variable "public_key" {
  description = "Path to SSH public key"
  type        = string
}

variable "script_path" {
  description = "Path to user-data script for instance setup"
  type        = string
}

variable "common_tags" {
  description = "Common tags to attach to resources"
  type        = map(string)
}
variable "key_name" {
  description = "SSH key pair name"
  type        = string
}
