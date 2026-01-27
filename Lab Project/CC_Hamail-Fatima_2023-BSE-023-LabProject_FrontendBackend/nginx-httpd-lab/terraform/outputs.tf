output "frontend_private_ip" {
  value = aws_instance.frontend.private_ip
}

output "backend_public_ips" {
  value = aws_instance.backend.*.public_ip
}