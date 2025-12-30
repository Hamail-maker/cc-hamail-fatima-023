variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "env_prefix" {
  description = "Environment prefix"
  type        = string
}

variable "my_ip" {
  description = "My public IP"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
}
