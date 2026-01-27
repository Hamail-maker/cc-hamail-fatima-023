# Lab Project - Frontend Backend Nginx HA - Complete Specifications

## Executive Summary

This lab project implements a **high-availability multi-tier web application architecture** using:
- **Terraform**: Infrastructure provisioning on AWS
- **Ansible**: Configuration management with role-based playbooks
- **Nginx**: Reverse proxy and load balancer
- **Apache HTTPD**: Backend web servers

The system demonstrates automatic failover, load distribution, and fully automated deployment from a single `terraform apply` command.

---

## Part A: Terraform Infrastructure Design (25 Marks)

### A.1 VPC and Networking (8 Marks)

#### VPC Configuration
```hcl
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}
```

- **CIDR Block**: `10.0.0.0/16` (configurable via `variables.tf`)
- **DNS Support**: Enabled for both hostnames and support
- **Tagging**: All resources tagged with `env_prefix` for easy identification

#### Public Subnet
```hcl
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}
```

- **CIDR Block**: `10.0.1.0/24` (supports up to 250+ instances)
- **Auto-assign Public IP**: Enabled for all instances
- **Single AZ**: All resources in `us-east-1a` for simplicity (can be extended to multi-AZ)

#### Internet Gateway
```hcl
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}
```

- Enables bidirectional Internet connectivity
- Attached to VPC and route table

#### Route Table
```hcl
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }
}
```

- **Default Route**: All traffic (0.0.0.0/0) routed through IGW
- **Route Table Association**: Attached to public subnet
- **Result**: Instances in subnet are reachable from Internet

### A.2 Security Groups (7 Marks)

#### Security Group Configuration
```hcl
resource "aws_security_group" "main" {
  name        = "nginx-ha-sg"
  description = "Security group for nginx-ha project"
  vpc_id      = aws_vpc.main.id
}
```

#### Ingress Rules

**SSH Access (Port 22)**
```hcl
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [local.my_ip]  # Your IP only
}
```

- **Source**: Your public IP (auto-detected via `icanhazip.com`)
- **Purpose**: Remote administration of EC2 instances
- **Security**: Restricted to single IP, preventing unauthorized SSH access

**HTTP Access (Port 80)**
```hcl
ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

- **Source**: Anywhere (0.0.0.0/0)
- **Purpose**: Web traffic to Nginx frontend
- **Note**: HTTPS (443) not included (outside lab scope)

#### Egress Rules

```hcl
egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
```

- Allows all outbound traffic for package installation and updates
- Necessary for `yum update` and service downloads

### A.3 EC2 Instances (10 Marks)

#### Frontend Instance (Nginx)

```hcl
resource "aws_instance" "frontend" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = aws_key_pair.deployer.key_name
  
  tags = {
    Name = "nginx-ha-frontend"
  }
}
```

- **AMI**: Latest Amazon Linux 2 (auto-detected)
- **Type**: t2.micro (free tier eligible)
- **Subnet**: Public subnet (receives public IP)
- **Role**: Reverse proxy and load balancer

#### Backend Instances (HTTPD) - 3 Instances

```hcl
resource "aws_instance" "backend" {
  count                  = 3
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = aws_key_pair.deployer.key_name
  
  tags = {
    Name = "nginx-ha-backend-${count.index}"
  }
}
```

- **Count**: 3 instances (for redundancy)
- **Naming**: `nginx-ha-backend-0`, `nginx-ha-backend-1`, `nginx-ha-backend-2`
- **Role**: Web servers serving distinct content

#### SSH Key Pair

```hcl
resource "aws_key_pair" "deployer" {
  key_name   = "nginx-ha-key"
  public_key = file(pathexpand(var.public_key_path))
}
```

- **Public Key**: From `~/.ssh/id_ed25519.pub` (must exist)
- **Purpose**: SSH authentication to instances
- **Management**: Key pair name in AWS, private key stored locally

#### Outputs (for reference)

```hcl
output "frontend_public_ip" {
  value = aws_instance.frontend.public_ip
}

output "backend_public_ips" {
  value = [for b in aws_instance.backend : b.public_ip]
}

output "backend_private_ips" {
  value = [for b in aws_instance.backend : b.private_ip]
}
```

---

## Part B: Ansible Roles & Playbook Structure (25 Marks)

### B.1 Role-Based Architecture (8 Marks)

The project uses **Ansible roles** for separation of concerns:

```
ansible/
├── roles/
│   ├── backend/          # HTTPD configuration
│   │   ├── tasks/        # Tasks to execute
│   │   ├── handlers/     # Handlers for service restart
│   │   └── templates/    # Jinja2 templates
│   └── frontend/         # Nginx configuration
│       ├── tasks/
│       ├── handlers/
│       └── templates/
└── playbooks/
    └── site.yaml         # Main playbook orchestrating roles
```

**Benefits**:
- **Modularity**: Each role handles specific responsibility
- **Reusability**: Roles can be used in multiple playbooks
- **Maintainability**: Easy to update individual components
- **Idempotence**: Ansible checks current state before applying changes

### B.2 Backend HTTPD Role (10 Marks)

#### Location
```
ansible/roles/backend/
├── tasks/main.yml
├── handlers/main.yml
└── templates/backend_index.html.j2
```

#### Tasks (tasks/main.yml)

```yaml
- name: Update yum cache
  yum:
    name: "*"
    state: latest
    update_cache: true

- name: Install Apache HTTPD
  yum:
    name:
      - httpd
      - wget
      - curl
    state: present

- name: Enable and start httpd service
  service:
    name: httpd
    state: started
    enabled: true

- name: Deploy backend index page
  template:
    src: backend_index.html.j2
    dest: /var/www/html/index.html
    owner: apache
    group: apache
    mode: '0644'
  notify: Restart httpd
```

**Key Points**:
- Updates system packages
- Installs Apache HTTPD and utilities
- Enables service to start on boot
- Deploys custom index page via Jinja2 template
- Notifies handler on template change for immediate effect

#### Handlers (handlers/main.yml)

```yaml
- name: Restart httpd
  service:
    name: httpd
    state: restarted
```

- Triggered only when template changes
- Ensures new content is immediately served
- Follows Ansible idempotence principle

#### Template (templates/backend_index.html.j2)

```html
<!DOCTYPE html>
<html>
<head>
    <title>Backend Server</title>
</head>
<body>
    <h1>Backend server: {{ inventory_hostname }}</h1>
    <p>Private IP: {{ ansible_default_ipv4.address }}</p>
    <p>Server #: {{ groups['backends'].index(inventory_hostname) + 1 }}</p>
</body>
</html>
```

**Variables Used**:
- `{{ inventory_hostname }}`: Current host's name from inventory
- `{{ ansible_default_ipv4.address }}`: Detected private IP
- `{{ groups['backends'].index(...) }}`: Server number (1, 2, or 3)

**Result**: Each backend serves a unique HTML page identifying itself.

### B.3 Frontend Nginx Role (10 Marks)

#### Location
```
ansible/roles/frontend/
├── tasks/main.yml
├── handlers/main.yml
└── templates/nginx_frontend.conf.j2
```

#### Tasks (tasks/main.yml)

```yaml
- name: Update yum cache
  yum:
    name: "*"
    state: latest
    update_cache: true

- name: Install Nginx
  yum:
    name:
      - nginx
      - wget
      - curl
    state: present

- name: Deploy Nginx configuration
  template:
    src: nginx_frontend.conf.j2
    dest: /etc/nginx/nginx.conf
    owner: root
    group: root
    mode: '0644'
  notify: Restart nginx

- name: Enable and start Nginx service
  service:
    name: nginx
    state: started
    enabled: true
```

**Key Points**:
- Installs Nginx from Amazon Linux 2 repository
- Deploys customized configuration with backend references
- Enables service to start on boot
- Restarts immediately if config changes

#### Handlers (handlers/main.yml)

```yaml
- name: Restart nginx
  service:
    name: nginx
    state: restarted
```

- Triggered when configuration file changes
- Ensures new routing rules take effect immediately

#### Template (templates/nginx_frontend.conf.j2)

```nginx
user nginx;
worker_processes auto;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer"';

    access_log /var/log/nginx/access.log main;

    upstream backend_servers {
        server {{ backend1_private_ip }}:80;
        server {{ backend2_private_ip }}:80;
        server {{ backup_backend_private_ip }}:80 backup;
    }

    server {
        listen 80;
        server_name _;

        location / {
            proxy_pass http://backend_servers;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

**Critical Components**:

1. **Upstream Definition** (Load Balancing)
   ```nginx
   upstream backend_servers {
       server 10.0.1.10:80;      # Backend 1 (Primary)
       server 10.0.1.11:80;      # Backend 2 (Primary)
       server 10.0.1.12:80 backup;  # Backend 3 (Backup/Failover)
   }
   ```
   - **Round-robin**: Default behavior distributes requests evenly
   - **Backup**: Server only used if both primary servers fail
   - **Private IPs**: Uses private IPs for internal communication

2. **Proxy Configuration**
   ```nginx
   location / {
       proxy_pass http://backend_servers;
       proxy_set_header Host $host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
   }
   ```
   - Passes requests to upstream block
   - Preserves client IP information
   - Enables proper logging and client identification

**Template Variables**:
- `{{ backend1_private_ip }}`: Private IP of backend 1
- `{{ backend2_private_ip }}`: Private IP of backend 2
- `{{ backup_backend_private_ip }}`: Private IP of backend 3

### B.4 Main Playbook (site.yaml) (7 Marks)

```yaml
---
- name: Configure backend HTTPD servers
  hosts: backends
  become: true
  gather_facts: true
  roles:
    - backend

- name: Configure frontend Nginx load balancer
  hosts: frontend
  become: true
  gather_facts: true
  vars:
    backend1_private_ip: "{{ hostvars[groups['backends'][0]].ansible_default_ipv4.address }}"
    backend2_private_ip: "{{ hostvars[groups['backends'][1]].ansible_default_ipv4.address }}"
    backup_backend_private_ip: "{{ hostvars[groups['backends'][2]].ansible_default_ipv4.address }}"
  roles:
    - frontend
```

**Key Features**:

1. **Two Play Blocks**: Separate configuration for backends and frontend
2. **Become**: Uses `become: true` for root privilege escalation
3. **Gather Facts**: Collects system information (IPs, hostnames, etc.)
4. **Dynamic Variables**: Extracts backend IPs from inventory facts
5. **Proper Role Usage**: Roles referenced, not tasks directly
6. **Dependency Order**: Backends configured before frontend

**Play 1: Backend Configuration**
- Targets: All hosts in `[backends]` group
- Applies: Backend role (installs HTTPD, deploys content)

**Play 2: Frontend Configuration**
- Targets: All hosts in `[frontend]` group
- Variables: Dynamically populates backend IPs from gathered facts
- Applies: Frontend role (installs Nginx, configures load balancing)

---

## Part C: Nginx Frontend + Backend HTTPD Behavior (25 Marks)

### C.1 Backend Distinct Content (8 Marks)

Each of 3 backends serves unique, identifiable content:

**Backend 1** (`nginx-ha-backend-0`):
```html
<h1>Backend server: ip-10-0-1-10.ec2.internal</h1>
<p>Private IP: 10.0.1.10</p>
<p>Server #: 1</p>
```

**Backend 2** (`nginx-ha-backend-1`):
```html
<h1>Backend server: ip-10-0-1-11.ec2.internal</h1>
<p>Private IP: 10.0.1.11</p>
<p>Server #: 2</p>
```

**Backend 3** (`nginx-ha-backend-2`):
```html
<h1>Backend server: ip-10-0-1-12.ec2.internal</h1>
<p>Private IP: 10.0.1.12</p>
<p>Server #: 3</p>
```

**Verification Method**:
```bash
curl http://<backend-1-ip>/    # Identify content source
curl http://<backend-2-ip>/    # Should differ from backend 1
curl http://<backend-3-ip>/    # Should differ from backends 1&2
```

### C.2 Nginx Reverse Proxy Configuration (8 Marks)

#### Upstream Block (2 Primary + 1 Backup)

```nginx
upstream backend_servers {
    server 10.0.1.10:80;           # Primary 1
    server 10.0.1.11:80;           # Primary 2
    server 10.0.1.12:80 backup;    # Backup (failover)
}
```

**Load Balancing Behavior**:

1. **Normal Operation** (All backends healthy):
   ```
   Request 1 → Backend 1
   Request 2 → Backend 2
   Request 3 → Backend 1
   Request 4 → Backend 2
   ...round-robin alternation...
   ```

2. **Primary Failure** (Backend 1 down):
   ```
   Request 1 → Backend 2
   Request 2 → Backend 2
   Request 3 → Backend 2
   ...Backend 3 NOT used...
   ```

3. **Both Primaries Down** (Backends 1 & 2 down):
   ```
   Request 1 → Backend 3 (backup)
   Request 2 → Backend 3 (backup)
   ...Backup server activated...
   ```

#### Location Block (Proxy Pass)

```nginx
location / {
    proxy_pass http://backend_servers;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

- **proxy_pass**: Routes to upstream block (intelligent distribution)
- **proxy_set_header**: Preserves client information in proxied requests
- **X-Real-IP**: Passes client's actual IP
- **X-Forwarded-For**: For identifying originating client behind proxy

### C.3 Upstream Failover Mechanism (9 Marks)

#### Backup Parameter

```nginx
server 10.0.1.12:80 backup;
```

- **Backup Keyword**: Marks server as standby/failover
- **Nginx Behavior**: 
  - Doesn't receive requests when primaries are healthy
  - Automatically receives all requests when both primaries fail
  - Detected via healthchecks (TCP connection attempts)

#### Testing Failover

**Test 1: Verify Round-Robin (2 Primaries)**
```bash
for i in {1..10}; do curl -s http://<frontend-ip>/ | grep "Server #"; done
```
Expected output shows alternating Backend #1 and #2 responses.

**Test 2: Single Primary Failure**
```bash
# SSH to Backend 1 and stop HTTPD
ssh -i ~/.ssh/id_ed25519 ec2-user@<backend-1-ip>
sudo systemctl stop httpd

# Now requests should go to Backend 2 only
for i in {1..5}; do curl -s http://<frontend-ip>/ | grep "Server #"; done
```
Expected: All responses show Backend #2.

**Test 3: Both Primaries Failed (Backup Activation)**
```bash
# SSH to Backend 2 and stop HTTPD (Backend 1 already down)
ssh -i ~/.ssh/id_ed25519 ec2-user@<backend-2-ip>
sudo systemctl stop httpd

# Now requests should go to Backend 3 (backup)
for i in {1..5}; do curl -s http://<frontend-ip>/ | grep "Server #"; done
```
Expected: All responses show Backend #3.

**Test 4: Recovery (Bring Primaries Back)**
```bash
# SSH to Backend 1 and restart HTTPD
ssh -i ~/.ssh/id_ed25519 ec2-user@<backend-1-ip>
sudo systemctl start httpd

# Give Nginx time to detect recovery (~5-10 seconds)
sleep 10

# Requests should resume alternating between Backends 1 & 2
for i in {1..10}; do curl -s http://<frontend-ip>/ | grep "Server #"; done
```
Expected: Responses alternate between Backend #1 and #2, Backend #3 no longer receives traffic.

#### Nginx Status and Logs

```bash
# Access Nginx status endpoint
curl http://<frontend-ip>/nginx_status

# Monitor access log to verify request distribution
ssh -i ~/.ssh/id_ed25519 ec2-user@<frontend-ip>
tail -f /var/log/nginx/access.log

# Check error log for backend failures
cat /var/log/nginx/error.log
```

Log entries show upstream server selection:
```
10.0.0.1 - - [26/Jan/2024 10:15:23] "GET / HTTP/1.1" 200 245 "-" "curl/7.64.1"
[upstream timed out (110: Connection timed out) while connecting to upstream]
```

---

## Part D: Terraform–Ansible Automation & Idempotence (15 Marks)

### D.1 Automatic Ansible Trigger (8 Marks)

#### Null Resource in Terraform

```hcl
resource "null_resource" "ansible_provisioner" {
  triggers = {
    frontend_id  = aws_instance.frontend.id
    backend_ids  = join(",", [for b in aws_instance.backend : b.id])
    inventory_md5 = md5(local_file.ansible_inventory.content)
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for instances to be ready..."
      sleep 30
      
      echo "Running Ansible playbooks..."
      cd ${path.module}/ansible
      
      ANSIBLE_HOST_KEY_CHECKING=False \
      ansible-playbook \
        -i inventory/hosts \
        -u ec2-user \
        --private-key ${pathexpand(var.private_key_path)} \
        playbooks/site.yaml
    EOT
  }

  depends_on = [
    local_file.ansible_inventory
  ]
}
```

**How It Works**:

1. **Triggers**: Watches for changes in instance IDs or inventory file
   - If frontend instance changes → Re-run Ansible
   - If backend instances change → Re-run Ansible
   - If inventory content changes → Re-run Ansible

2. **Dependencies**: Waits for inventory file to be generated first
   - `local_file.ansible_inventory` must exist before provisioner runs

3. **Local-Exec**: Runs shell command on machine running Terraform
   - Not executed on remote instances
   - Allows orchestration of local tools (Ansible)

4. **Sleep 30**: Waits for EC2 instances to fully boot
   - SSH service needs time to start
   - Instances need to assign private IPs and network configuration

5. **Ansible Execution**: Runs playbooks with:
   - Generated inventory file (`inventory/hosts`)
   - EC2-user for Amazon Linux 2
   - SSH private key for authentication
   - Disabled host key checking

### D.2 Single Command Deployment (4 Marks)

#### Execution Flow

```bash
terraform apply -auto-approve
```

This single command performs:

1. **Terraform Phase** (1-2 minutes):
   ```
   ✓ Validates configuration
   ✓ Creates VPC
   ✓ Creates Subnet
   ✓ Creates Internet Gateway
   ✓ Creates Route Table
   ✓ Creates Security Group
   ✓ Creates Key Pair
   ✓ Launches Frontend EC2 instance
   ✓ Launches Backend EC2 instances (3x)
   ✓ Generates inventory file
   ```

2. **Wait Phase** (30 seconds):
   ```
   Waiting for instances to be ready...
   (SSH service starting, networking initialization)
   ```

3. **Ansible Phase** (2-4 minutes):
   ```
   ✓ Backend 1: Install HTTPD, deploy content
   ✓ Backend 2: Install HTTPD, deploy content
   ✓ Backend 3: Install HTTPD, deploy content
   ✓ Frontend: Install Nginx, deploy config with backend IPs
   ```

**No Manual Steps**:
- ❌ No manual `terraform destroy` and re-apply needed
- ❌ No manual inventory file creation
- ❌ No manual `ansible-playbook` execution
- ❌ No manual configuration of backend IPs in Nginx
- ✅ Everything automated in single `terraform apply` command

### D.3 Idempotence (3 Marks)

#### Idempotent Ansible Tasks

All Ansible tasks are idempotent (safe to run multiple times):

```yaml
- name: Install Apache HTTPD
  yum:
    name: httpd
    state: present    # ✓ Idempotent: Only installs if missing
    
- name: Enable and start httpd service
  service:
    name: httpd
    state: started    # ✓ Idempotent: Only starts if stopped
    enabled: true     # ✓ Idempotent: Only enables if disabled
    
- name: Deploy backend index page
  template:
    src: backend_index.html.j2
    dest: /var/www/html/index.html
    owner: apache
    group: apache
    mode: '0644'      # ✓ Idempotent: Only notifies if content changes
  notify: Restart httpd  # Handler only runs if template changed
```

#### Testing Idempotence

```bash
# First run: Creates everything
terraform apply -auto-approve
# Expected: Shows "Plan: 8 to add"

# Second run: No changes
terraform apply -auto-approve
# Expected: Shows "No changes. Infrastructure is up-to-date"

# Or re-run Ansible playbook directly
cd ansible
ansible-playbook -i inventory/hosts playbooks/site.yaml
# Expected: All tasks show "ok" (not "changed")
```

#### Sample Idempotent Output

```
TASK [backend : Install Apache HTTPD]
ok: [10.0.1.10]    ← Already installed, no change

TASK [backend : Enable and start httpd service]
ok: [10.0.1.10]    ← Already enabled and running

TASK [backend : Deploy backend index page]
ok: [10.0.1.10]    ← Content identical, no handler triggered

PLAY RECAP
10.0.1.10 : ok=3 changed=0 unreachable=0 failed=0
```

#### No Unnecessary Changes

Terraform triggers are designed to avoid unnecessary re-runs:

```hcl
triggers = {
  frontend_id  = aws_instance.frontend.id    # Only triggers if instance replaced
  backend_ids  = join(",", [for b in aws_instance.backend : b.id])
  inventory_md5 = md5(local_file.ansible_inventory.content)  # Only if IPs change
}
```

If instance IPs don't change (normal case), Ansible isn't re-triggered unnecessarily.

---

## Part E: Code Quality, Documentation & Git Usage (10 Marks)

### E.1 Directory Structure & Code Quality (5 Marks)

#### Clean Organization

```
CC_Hamail-Fatima_2023-BSE-023-LabProject_FrontendBackend/
│
├── *.tf              # Terraform files (main, variables, outputs, locals)
├── *.tfvars          # Variable values (should be in .gitignore)
│
├── ansible/
│   ├── ansible.cfg   # Global Ansible settings
│   ├── inventory/
│   │   ├── hosts     # Generated inventory (should be in .gitignore)
│   │   └── hosts.tpl # Inventory template
│   ├── playbooks/
│   │   └── site.yaml # Main playbook
│   └── roles/
│       ├── backend/  # Backend HTTPD role
│       │   ├── tasks/main.yml
│       │   ├── handlers/main.yml
│       │   ├── templates/backend_index.html.j2
│       │   └── vars/main.yml (optional)
│       └── frontend/ # Frontend Nginx role
│           ├── tasks/main.yml
│           ├── handlers/main.yml
│           ├── templates/nginx_frontend.conf.j2
│           └── vars/main.yml (optional)
│
├── .gitignore        # Excludes sensitive files
├── README.md         # Project overview and instructions
└── Lab-Project-*.md  # Detailed specifications (this file)
```

#### Code Comments and Clarity

**Terraform Example** (main.tf):
```hcl
# VPC - Virtual Private Cloud for isolated networking
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block  # 10.0.0.0/16 by default
  enable_dns_hostnames = true                 # For meaningful hostnames
  enable_dns_support   = true                 # For DNS resolution

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

# Internet Gateway - Enables bidirectional Internet connectivity
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id  # Must be attached to VPC

  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

# Public Subnet - Subnet within VPC where instances are deployed
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_block  # 10.0.1.0/24
  availability_zone       = var.availability_zone  # us-east-1a
  map_public_ip_on_launch = true                   # Auto-assign public IPs

  tags = {
    Name = "${var.env_prefix}-public-subnet"
  }
}
```

**Ansible Example** (roles/backend/tasks/main.yml):
```yaml
---
# Backend HTTPD Role - Installs and configures Apache web server

# Update package cache to latest available versions
- name: Update yum cache
  yum:
    name: "*"
    state: latest
    update_cache: true

# Install Apache HTTPD and utilities
- name: Install Apache HTTPD
  yum:
    name:
      - httpd           # Apache HTTP Server
      - wget            # Download utility
      - curl            # Data transfer tool
    state: present

# Enable service to start on boot and start immediately
- name: Enable and start httpd service
  service:
    name: httpd
    state: started      # Start service now
    enabled: true       # Start on boot

# Deploy unique content page identifying this backend server
# Uses Jinja2 templating to insert dynamic values (hostname, IP)
- name: Deploy backend index page
  template:
    src: backend_index.html.j2
    dest: /var/www/html/index.html
    owner: apache       # Apache user for proper permissions
    group: apache
    mode: '0644'        # Readable by all, writable by owner
  notify: Restart httpd # Trigger handler if file changed
```

#### Variable Naming

**Terraform Variables** (variables.tf):
```hcl
variable "aws_region" {
  description = "AWS region to deploy resources"    # Clear description
  type        = string                               # Explicit type
  default     = "us-east-1"                          # Safe default
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "env_prefix" {
  description = "Environment prefix for resource naming"
  type        = string
  default     = "nginx-ha"
}
```

**Ansible Variables** (in templates):
```jinja2
{{ inventory_hostname }}           # Host's name from inventory - Clear
{{ ansible_default_ipv4.address }} # Detected private IP - Descriptive
{{ groups['backends'][0] }}        # First backend host - Self-explanatory
```

### E.2 Documentation (3 Marks)

#### README.md

Comprehensive documentation including:
- **Project Overview**: What the project does
- **Architecture Diagram**: Visual representation of infrastructure
- **Project Structure**: File organization explanation
- **Prerequisites**: Software and setup requirements
- **Step-by-Step Execution**: Running Terraform and verifying deployment
- **Verification Instructions**: Testing all features
- **Customization Guide**: How to modify settings
- **Cleanup Instructions**: Destroying resources
- **Troubleshooting**: Common issues and solutions

#### Lab-Project-Frontend-Backend-Nginx-HA.md

Detailed specifications document covering:
- **Part A**: Terraform infrastructure design with code examples
- **Part B**: Ansible role structure and configurations
- **Part C**: Nginx/HTTPD behavior and failover testing
- **Part D**: Automation and idempotence mechanisms
- **Part E**: Code quality and documentation

#### Code Comments

Every complex section includes:
- What it does (purpose)
- Why it's done (reason)
- How it works (mechanism)
- Example outputs/results

### E.3 Git Usage (2 Marks)

#### .gitignore

```
.terraform/*
*.tfstate
*.tfstate.*
.terraform.lock.hcl
*.pem
*.key
*.pub
.env
.envrc

ansible/inventory/hosts
ansible/*.retry

.vscode/
.idea/
*.swp
*~
```

**Excluded Items**:
- ❌ Terraform state files (*.tfstate) - Contains sensitive data, IPs
- ❌ Lock files (.terraform.lock.hcl) - Generated, not committed
- ❌ Private keys (*.pem, *.key, id_ed25519) - SECURITY CRITICAL
- ❌ Public keys (*.pub) - Better practices for sharing via secure channels
- ❌ Generated inventory (hosts) - Created by Terraform
- ❌ Terraform cache (.terraform/) - Generated during `init`

**Included Items**:
- ✅ main.tf, variables.tf, outputs.tf - Infrastructure code
- ✅ ansible/roles/ - Configuration templates and tasks
- ✅ README.md, Lab-Project-*.md - Documentation
- ✅ .gitignore - This file itself

#### Git Commit Examples

```bash
# After creating Terraform files
git add *.tf
git commit -m "feat: Add Terraform infrastructure configuration

- Create VPC with public subnet and IGW
- Define security groups for SSH and HTTP access
- Create 1 frontend and 3 backend EC2 instances
- Add null_resource for Ansible integration"

# After adding Ansible roles
git add ansible/
git commit -m "feat: Add Ansible roles for frontend and backend

- Create backend role with HTTPD installation and HTML templates
- Create frontend role with Nginx reverse proxy configuration
- Implement main playbook orchestrating both roles
- Add dynamic variable passing for backend IP addresses"

# After documentation
git add README.md Lab-Project-*.md .gitignore
git commit -m "docs: Add comprehensive documentation

- Add README with architecture and execution steps
- Create detailed specifications document
- Add .gitignore for sensitive files"
```

#### Clean Repository

```bash
# Verify no secrets committed
git log --all -p -- '*.pem'
git log --all -p -- '*.key'
git log --all -p -- 'inventory/hosts'

# No terraform state
git ls-files | grep tfstate

# No credentials
git log -p | grep -i 'aws_access_key'
```

---

## Marking Checklist

### A. Terraform Infrastructure Design (25 Marks)

- [ ] **VPC Setup (8 marks)**
  - [ ] VPC created with correct CIDR block (10.0.0.0/16)
  - [ ] Public subnet created (10.0.1.0/24)
  - [ ] Internet Gateway attached and routes configured
  - [ ] Route table with default route (0.0.0.0/0) to IGW
  - [ ] All resources properly tagged

- [ ] **Security Groups (7 marks)**
  - [ ] SSH ingress restricted to student's IP (via icanhazip.com)
  - [ ] HTTP ingress (port 80) open to 0.0.0.0/0
  - [ ] Egress allows all traffic for package installation
  - [ ] Security group attached to all instances
  - [ ] No unnecessary open ports

- [ ] **EC2 Instances (10 marks)**
  - [ ] 1 Frontend instance (tagged as "frontend")
  - [ ] 3 Backend instances (tagged as "backend-0", "backend-1", "backend-2")
  - [ ] All use t2.micro (or similar)
  - [ ] All use latest Amazon Linux 2 AMI
  - [ ] Public IPs assigned automatically
  - [ ] Key pair configured for SSH

### B. Ansible Roles & Playbook Structure (25 Marks)

- [ ] **Role Usage (8 marks)**
  - [ ] Backend role exists in ansible/roles/backend/
  - [ ] Frontend role exists in ansible/roles/frontend/
  - [ ] Both roles properly referenced in main playbook
  - [ ] No tasks directly in playbook (must use roles)
  - [ ] Role structure follows Ansible best practices

- [ ] **Backend Role (10 marks)**
  - [ ] Installs Apache HTTPD
  - [ ] Enables and starts HTTPD service
  - [ ] Uses template for index.html deployment
  - [ ] Each backend serves distinct, identifiable content
  - [ ] Handlers properly configured for restarts
  - [ ] Template includes inventory_hostname variable
  - [ ] Template includes private IP information

- [ ] **Frontend Role (10 marks)**
  - [ ] Installs Nginx
  - [ ] Enables and starts Nginx service
  - [ ] Deploys Nginx config via template
  - [ ] Config includes upstream block with 3 servers
  - [ ] Upstream has 2 primary + 1 backup configuration
  - [ ] Proxy passes to upstream block (not direct IPs)
  - [ ] Template variables properly substituted

- [ ] **Playbook Structure (7 marks)**
  - [ ] site.yaml uses roles (not inline tasks)
  - [ ] Separate plays for frontend and backend
  - [ ] become: true for privilege escalation
  - [ ] gather_facts enabled for variable collection
  - [ ] Dynamic variable extraction from facts
  - [ ] Proper ordering (backends before frontend)

### C. Nginx Frontend + Backend HTTPD Behavior (25 Marks)

- [ ] **Distinct Backend Content (8 marks)**
  - [ ] Backend 1 serves unique HTML identifying itself
  - [ ] Backend 2 serves unique HTML identifying itself
  - [ ] Backend 3 serves unique HTML identifying itself
  - [ ] Content includes hostname and/or IP address
  - [ ] Each can be individually curled and verified
  - [ ] Content visibly different from other backends

- [ ] **Nginx Reverse Proxy (8 marks)**
  - [ ] Nginx installed and running on frontend
  - [ ] Upstream block references all 3 backends (by private IP)
  - [ ] Location / proxies to upstream block
  - [ ] Proxy headers properly configured
  - [ ] Frontend serves content from backends
  - [ ] Frontend accessible via public IP
  - [ ] Backend private IPs correctly configured

- [ ] **Upstream Failover (9 marks)**
  - [ ] Upstream defined with 2 primary servers
  - [ ] Third server marked as "backup"
  - [ ] Normal operation: requests alternate between 2 primaries
  - [ ] Primary failure: requests go to remaining primary
  - [ ] Both primaries down: requests served by backup
  - [ ] Recovery: primaries resume serving when restored
  - [ ] Failover verified through repeated curl requests
  - [ ] Round-robin distribution verified
  - [ ] Backup-only mode verified when primaries stopped

### D. Terraform–Ansible Automation & Idempotence (15 Marks)

- [ ] **Terraform Triggers Ansible (8 marks)**
  - [ ] null_resource provisioner exists in Terraform
  - [ ] Provisioner runs local-exec with ansible-playbook
  - [ ] Inventory file generated by Terraform
  - [ ] Provisioner waits for instances (sleep 30)
  - [ ] No manual ansible-playbook command needed
  - [ ] Playbook runs automatically after terraform apply
  - [ ] Correct inventory file path used
  - [ ] Correct ssh key and user specified

- [ ] **Single terraform apply Command (4 marks)**
  - [ ] terraform apply -auto-approve creates everything
  - [ ] No intermediate manual steps required
  - [ ] All instances created in one apply
  - [ ] All configuration applied automatically
  - [ ] No separate terraform destroy/apply needed
  - [ ] No missing prerequisites

- [ ] **Idempotence (3 marks)**
  - [ ] Re-running terraform apply shows no changes
  - [ ] Re-running ansible-playbook shows no changes
  - [ ] All Ansible tasks are idempotent
  - [ ] No errors on re-runs
  - [ ] Service states preserved correctly

### E. Code Quality, Documentation & Git Usage (10 Marks)

- [ ] **Code Organization (5 marks)**
  - [ ] Clear directory structure
  - [ ] Terraform files in root directory
  - [ ] Ansible files in ansible/ directory
  - [ ] Roles in ansible/roles/ directory
  - [ ] Templates in proper role template directories
  - [ ] Meaningful variable names
  - [ ] Comments explaining complex logic
  - [ ] No hardcoded values (use variables)
  - [ ] Consistent formatting and indentation

- [ ] **Documentation (3 marks)**
  - [ ] README.md with overview and instructions
  - [ ] Architecture diagram or description
  - [ ] Prerequisites section
  - [ ] Step-by-step execution guide
  - [ ] Verification instructions
  - [ ] Troubleshooting section
  - [ ] Customization guide
  - [ ] Lab-Project-*.md with detailed specs

- [ ] **Git Usage (2 marks)**
  - [ ] .gitignore excludes terraform state files
  - [ ] .gitignore excludes private keys and credentials
  - [ ] .gitignore excludes generated files
  - [ ] No .tfstate files committed
  - [ ] No private keys committed
  - [ ] Clean commit history
  - [ ] Meaningful commit messages
  - [ ] All source code committed

---

## Running the Complete Project

### Quick Start

```bash
# Prerequisites: AWS CLI configured, Terraform installed, Ansible installed, SSH key ready

# 1. Clone repo
cd CC_Hamail-Fatima_2023-BSE-023-LabProject_FrontendBackend

# 2. Initialize Terraform
terraform init

# 3. Deploy everything (VPC, instances, Ansible configuration)
terraform apply -auto-approve

# 4. Wait 5-7 minutes for all instances to boot and configure

# 5. Get the frontend IP
FRONTEND_IP=$(terraform output -raw frontend_public_ip)
echo "Frontend: http://$FRONTEND_IP/"

# 6. Test load balancing
for i in {1..10}; do 
  curl -s http://$FRONTEND_IP/ | grep "Server #"
done

# 7. Test failover (stop backends 1 & 2, verify backup serves)
# ... (see verification section above)

# 8. Cleanup when done
terraform destroy -auto-approve
```

---

## Conclusion

This lab project integrates modern Infrastructure as Code (Terraform) with configuration management (Ansible roles) to deploy a production-grade high-availability web application architecture. The emphasis on automation, role-based configuration, and proper documentation demonstrates DevOps best practices applicable to real-world deployments.

**Key Learning Outcomes Achieved**:
1. ✅ Terraform for AWS infrastructure provisioning
2. ✅ Ansible roles for modular configuration management
3. ✅ Nginx load balancing with failover
4. ✅ Terraform-Ansible integration for full automation
5. ✅ High availability and redundancy design
6. ✅ Production-grade code organization and documentation
7. ✅ Git best practices for infrastructure code

---

**Document Version**: 1.0  
**Last Updated**: January 2024  
**Author**: Lab Project Template
