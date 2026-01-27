output "frontend_public_ip" {
  description = "Public IP of frontend Nginx instance"
  value       = aws_instance.frontend.public_ip
}

output "frontend_private_ip" {
  description = "Private IP of frontend Nginx instance"
  value       = aws_instance.frontend.private_ip
}

output "backend_public_ips" {
  description = "Public IPs of backend HTTPD instances"
  value       = [for b in aws_instance.backend : b.public_ip]
}

output "backend_private_ips" {
  description = "Private IPs of backend HTTPD instances"
  value       = [for b in aws_instance.backend : b.private_ip]
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "Subnet ID"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.main.id
}

output "my_ip" {
  description = "Your public IP for SSH access"
  value       = local.my_ip
}
