# Troubleshooting Guide
This document provides guidance to diagnose and fix common issues in the Assignment-2 multi-tier web infrastructure.

## Common Issues

### 1. Nginx Fails to Start
**Symptoms:**
- `nginx -s reload` gives errors
- No web page is accessible

**Solution:**
- Test configuration: `nginx -t`
- Check logs: `/var/log/nginx/error.log`
- Look for syntax errors or port conflicts

---

### 2. Backend Servers Not Responding
**Symptoms:**
- Nginx returns 502/503 errors
- Health check script shows DOWN servers

**Solution:**
- Verify backend server IPs in Nginx upstream block
- Check backend server status
- Restart backend servers if necessary

---

### 3. Rate Limiting Not Working
**Symptoms:**
- Requests exceed limit but no 429 response
- No change in request behavior

**Solution:**
- Verify `limit_req_zone` and `limit_req` directives in Nginx config
- Reload Nginx: `nginx -s reload`
- Check logs for request patterns

## Log Locations

- Nginx Access Log: `/var/log/nginx/access.log`
- Nginx Error Log: `/var/log/nginx/error.log`
- Health Check Logs: `~/health_check/health_log.txt`
- Terraform Logs: Output from `terraform apply` or `terraform destroy`

## Debug Commands

- Check Nginx configuration: `nginx -t`
- Reload Nginx: `nginx -s reload`
- Tail Nginx logs: `tail -f /var/log/nginx/error.log`
- Check backend server connectivity: `curl http://<backend-ip>/`
- List EC2 instances by tag: 
  ```bash
  aws ec2 describe-instances --filters "Name=tag:Project,Values=Assignment-2"


---

## **Step 5: Optional Advanced Tips**

You can include **troubleshooting tips for advanced issues**:

```markdown
## Advanced Tips

- Health check script not logging:
  - Verify script permissions: `chmod +x health_check.sh`
  - Run manually to check errors: `./health_check.sh`
- Terraform state issues:
  - Run `terraform refresh` to sync state with AWS
  - Delete `.terraform/` folder and re-init if needed
