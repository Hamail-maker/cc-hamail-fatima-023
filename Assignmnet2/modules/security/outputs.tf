output "nginx_sg_id" {
  value       = aws_security_group.nginx_sg.id
  description = "ID of the Nginx security group"
}

output "backend_sg_id" {
  value       = aws_security_group.backend_sg.id
  description = "ID of the Backend security group"
}
