# =========================
# Deployment Configuration Guide
# =========================

output "configuration_guide" {
  value = <<-EOT

========================================
DEPLOYMENT SUCCESSFUL!
========================================

Next Steps:

1. SSH into Nginx server:
   ssh ec2-user@158.252.95.43

2. Edit Nginx configuration:
   sudo vim /etc/nginx/nginx.conf

3. Update backend private IPs in upstream block:
   - web-1
   - web-2
   - web-3

4. Restart Nginx:
   sudo systemctl restart nginx

5. Open browser:
   https:158.252.95.43

========================================
EOT
}
