# Lab Project: Terraform + Ansible - Nginx Frontend with HA Backend HTTPD Servers

## Overview

This lab project demonstrates a production-grade multi-tier AWS infrastructure deployment using **Terraform** for Infrastructure as Code (IaC) and **Ansible** roles for configuration management. The architecture consists of:

- **1 Frontend (Nginx)**: Acts as a reverse proxy and load balancer
- **3 Backend Servers (HTTPD)**: Running Apache HTTP servers with distinct content
- **High Availability**: 2 active backends + 1 backup backend for failover

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          AWS VPC (10.0.0.0/16)                  │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                   Public Subnet (10.0.1.0/24)               ││
│  │                                                              ││
│  │  ┌──────────────────┐                                       ││
│  │  │   Nginx Frontend │                                       ││
│  │  │  (Reverse Proxy) │                                       ││
│  │  │   Load Balancer  │                                       ││
│  │  └────────┬─────────┘                                       ││
│  │           │                                                  ││
│  │      ┌────┴────┬────────────┬─────────────────┐             ││
│  │      │         │            │                 │             ││
│  │      ▼         ▼            ▼                 ▼             ││
│  │  ┌──────┐  ┌──────┐     ┌──────┐         ┌──────┐          ││
│  │  │ HTTPD│  │ HTTPD│     │ HTTPD│ (BACKUP)│ HTTPD│          ││
│  │  │  #1  │  │  #2  │     │  #3  │ ◄────── │  #4  │          ││
│  │  │(Primary)(Primary)    (Active)         (Standby)         ││
│  │  └──────┘  └──────┘     └──────┘         └──────┘          ││
│  │                                                              ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │              Internet Gateway (IGW)                          ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

## Project Structure

```
CC_Hamail-Fatima_2023-BSE-023-LabProject_FrontendBackend/
├── main.tf                          # Main Terraform configuration
├── variables.tf                     # Variable definitions
├── outputs.tf                       # Output values
├── locals.tf                        # Local values and data sources
├── terraform.tfvars                 # Variable values
│
├── ansible/
│   ├── ansible.cfg                 # Ansible configuration
│   ├── inventory/
│   │   ├── hosts                   # Generated inventory (created by Terraform)
│   │   └── hosts.tpl               # Inventory template
│   ├── playbooks/
│   │   └── site.yaml               # Main playbook using roles
│   └── roles/
│       ├── backend/                # HTTPD backend role
│       │   ├── tasks/
│       │   │   └── main.yml
│       │   ├── handlers/
│       │   │   └── main.yml
│       │   ├── templates/
│       │   │   └── backend_index.html.j2
│       │   └── vars/
│       │       └── main.yml
│       └── frontend/               # Nginx frontend role
│           ├── tasks/
│           │   └── main.yml
│           ├── handlers/
│           │   └── main.yml
│           ├── templates/
│           │   └── nginx_frontend.conf.j2
│           └── vars/
│               └── main.yml
│
├── .gitignore
├── README.md
└── Lab-Project-Frontend-Backend-Nginx-HA.md
```

## Prerequisites

### Local Environment

1. **Terraform** (>= 1.0)
   ```bash
   # Install on Windows, macOS, or Linux
   # https://www.terraform.io/downloads
   ```

2. **AWS CLI** configured with credentials
   ```bash
   aws configure
   # Enter your AWS Access Key ID, Secret Access Key, Region, and Output format
   ```

3. **Ansible** (>= 2.9)
   ```bash
   # On Linux/macOS:
   pip install ansible

   # On Windows (via WSL or Git Bash):
   pip install ansible
   ```

4. **SSH Key Pair**
   ```bash
   # Generate SSH key if not exists
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
   ```

5. **Python 3** (for Ansible)
   ```bash
   python3 --version  # Should be 3.6+
   ```

### AWS Account

- AWS account with appropriate IAM permissions for EC2, VPC, and security groups
- No special VPC setup needed; Terraform creates all networking resources

## Step-by-Step Execution

### 1. Clone and Navigate to Project

```bash
cd CC_Hamail-Fatima_2023-BSE-023-LabProject_FrontendBackend
```

### 2. Initialize Terraform

```bash
terraform init
```

This downloads required Terraform providers and initializes the working directory.

### 3. Review the Plan (Optional)

```bash
terraform plan
```

Displays what resources Terraform will create without actually creating them.

### 4. Apply Terraform Configuration

```bash
terraform apply -auto-approve
```

This will:
- Create VPC, subnet, Internet Gateway, route tables
- Create security groups with SSH (from your IP) and HTTP (from anywhere) access
- Launch 1 Nginx frontend instance and 3 HTTPD backend instances
- Generate Ansible inventory file automatically
- **Automatically run Ansible playbooks** to configure all instances (no manual Ansible command needed!)

**Expected Output:**
```
...
frontend_public_ip = "54.123.45.67"
backend_public_ips = ["54.123.45.68", "54.123.45.69", "54.123.45.70"]
```

### 5. Wait for Setup (Important!)

The `terraform apply` command includes a 30-second wait before running Ansible playbooks to allow instances to fully boot. The complete setup typically takes **5-7 minutes**.

Watch the output for:
```
aws_instance.frontend: Creation complete after ...
aws_instance.backend[0]: Creation complete after ...
aws_instance.backend[1]: Creation complete after ...
aws_instance.backend[2]: Creation complete after ...
null_resource.ansible_provisioner: Provisioning with 'local-exec'...
PLAY [Install and configure backend HTTPD servers]
PLAY [Install and configure frontend Nginx load balancer]
```

## Verification

### 1. Check Backend Servers Individually

```bash
curl http://<backend-1-public-ip>/
curl http://<backend-2-public-ip>/
curl http://<backend-3-public-ip>/
```

Each should show a distinct HTML page identifying the server.

### 2. Test Frontend Load Balancer

```bash
# Run this multiple times - should alternate between backend 1 and 2
curl http://<frontend-public-ip>/

# Check access logs to verify distribution
ssh -i ~/.ssh/id_ed25519 ec2-user@<frontend-public-ip>
tail -f /var/log/nginx/access.log
```

### 3. Test Backup Functionality

```bash
# SSH into frontend
ssh -i ~/.ssh/id_ed25519 ec2-user@<frontend-public-ip>

# Stop primary backends
ssh -i ~/.ssh/id_ed25519 ec2-user@<backend-1-public-ip>
sudo systemctl stop httpd

ssh -i ~/.ssh/id_ed25519 ec2-user@<backend-2-public-ip>
sudo systemctl stop httpd

# Now requests should be served by backup (backend 3)
curl http://<frontend-public-ip>/
```

You should see responses from backend 3 only.

### 4. Verify Nginx Configuration

```bash
ssh -i ~/.ssh/id_ed25519 ec2-user@<frontend-public-ip>
cat /etc/nginx/nginx.conf | grep -A 20 "upstream backend_servers"
```

Should show:
```
upstream backend_servers {
    server 10.0.1.x:80;
    server 10.0.1.y:80;
    server 10.0.1.z:80 backup;
}
```

## Important Assumptions & Configuration

1. **AWS Region**: Default is `us-east-1` (change in `terraform.tfvars` if needed)
2. **Instance Type**: `t2.micro` (eligible for AWS free tier)
3. **AMI**: Latest Amazon Linux 2 (automatically detected)
4. **SSH Access**: Restricted to your current public IP (auto-detected via icanhazip.com)
5. **HTTP Access**: Open to 0.0.0.0/0 (internet-wide)
6. **Ansible User**: `ec2-user` (default for Amazon Linux 2)

## Customization

### Change AWS Region

Edit `terraform.tfvars`:
```hcl
aws_region = "us-west-2"  # or any other region
```

### Change Instance Type

```hcl
instance_type = "t2.small"  # for more resources
```

### Modify Load Balancing Behavior

Edit `ansible/roles/frontend/templates/nginx_frontend.conf.j2`:
- Change `round-robin` to other algorithms: `least_conn`, `ip_hash`, `random`, etc.
- Add weights: `server 10.0.1.x:80 weight=2;`

### Adjust Backend Content

Edit `ansible/roles/backend/templates/backend_index.html.j2` to customize the HTML response.

## Cleanup

To destroy all AWS resources (saves costs):

```bash
terraform destroy -auto-approve
```

This removes:
- EC2 instances
- VPC, subnet, and networking
- Security groups
- Key pair

## Troubleshooting

### Ansible Fails After Terraform Apply

**Issue**: `"SSH Error: data could not be sent to the remote command"

**Solutions**:
1. Increase the wait time in `main.tf` (increase `sleep 30` to `sleep 60`)
2. SSH into instances manually first to accept host keys:
   ```bash
   ssh -i ~/.ssh/id_ed25519 ec2-user@<public-ip> exit
   ```
3. Set `ANSIBLE_HOST_KEY_CHECKING=False` (already done in Terraform)

### Nginx Won't Start

**Check logs**:
```bash
ssh -i ~/.ssh/id_ed25519 ec2-user@<frontend-public-ip>
sudo journalctl -u nginx -n 50
```

**Verify config syntax**:
```bash
sudo nginx -t
```

### Backend Not Responding

**Check HTTPD status**:
```bash
ssh -i ~/.ssh/id_ed25519 ec2-user@<backend-public-ip>
sudo systemctl status httpd
sudo journalctl -u httpd -n 50
```

### Terraform State Locked

```bash
terraform force-unlock <LOCK_ID>  # Use the lock ID from error message
```

## Idempotence Testing

Run Terraform apply again to verify idempotence:

```bash
terraform apply -auto-approve
```

**Expected Result**: Should show `No changes. Infrastructure is up-to-date.` or minimal changes with no errors.

## Key Concepts Demonstrated

1. **Infrastructure as Code (IaC)**: Terraform for reproducible AWS deployments
2. **Configuration Management**: Ansible roles for separation of concerns
3. **High Availability**: Nginx upstream with backup server
4. **Load Balancing**: Round-robin distribution across primary servers
5. **Automation**: Terraform triggers Ansible automatically (null_resource)
6. **Idempotence**: Playbooks can be run multiple times safely
7. **Dynamic Inventory**: Terraform generates Ansible inventory
8. **Security**: SSH key-based authentication, scoped security groups

## Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Ansible Documentation](https://docs.ansible.com)
- [Nginx Upstream](https://nginx.org/en/docs/http/ngx_http_upstream_module.html)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)

## Marking Criteria Coverage

- **A. Terraform Infrastructure Design (25 marks)**: VPC, subnet, IGW, route tables, SGs, EC2 instances ✅
- **B. Ansible Roles (25 marks)**: Backend and frontend roles with templates and handlers ✅
- **C. Nginx + HTTPD Behavior (25 marks)**: Load balancing with 2 primary + 1 backup ✅
- **D. Terraform-Ansible Automation (15 marks)**: Automatic Ansible execution via null_resource ✅
- **E. Code Quality & Documentation (10 marks)**: Clear structure, comments, this README ✅

---

**Author**: CC_Hamail-Fatima_2023-BSE-023  
**Date**: 2024  
**Course**: Infrastructure as Code with Terraform & Ansible
