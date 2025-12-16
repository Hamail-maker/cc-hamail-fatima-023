# Cloud Computing Lab 09

**Submitted To:** Sir Waqas
**Submitted By:** Hamail Fatima
**Roll No:** 2023-BSE-023
**Section:** 5(A)

---

## Task 1 — GitHub CLI, Codespace Setup and Authentication

### Goal

Install GitHub CLI, authenticate with GitHub, create/connect to a Codespace, and perform all lab work inside the Codespace.

### Steps

1. **Install GitHub CLI (Windows example):**

   ```bash
   winget install --id GitHub.cli
   ```

   **Screenshot:** `task1_gh_install.png`

2. **Authenticate GitHub CLI for Codespaces:**

   ```bash
   gh auth login -s codespace
   ```

   * Generate a **GitHub Access Token (classic)** with scopes:

     * `admin:org`
     * `codespace`
     * `repo`
       **Screenshot:** `task1_gh_auth_login.png`

3. **List available Codespaces (optional):**

   ```bash
   gh codespace list
   ```

   **Screenshot:** `task1_codespace_list.png`

4. **Create or connect to a Codespace:**

   ```bash
   gh codespace create --repo <owner>/<repo> --branch main --machine basicLinux32gb
   # OR
   gh codespace ssh -c <codespace_name>
   ```

   **Screenshot:** `task1_codespace_ssh_connected.png`

---

## Task 2 — Install AWS CLI in Codespace and Configure

### Goal

Install and configure AWS CLI inside the Codespace.

### Steps

1. **Download and install AWS CLI:**

   ```bash
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   ```

   **Screenshot:** `task2_aws_install_and_version.png`

2. **Verify installation:**

   ```bash
   aws --version
   ```

3. **Configure AWS CLI:**

   ```bash
   aws configure
   ```

   Enter:

   * AWS Access Key ID
   * AWS Secret Access Key
   * Default region (e.g., `me-central-1`)
   * Output format (`json`)
     **Screenshot:** `task2_aws_configure_and_files.png`

4. **Verify config files:**

   ```bash
   cat ~/.aws/credentials
   cat ~/.aws/config
   ```

5. **Verify connectivity:**

   ```bash
   aws sts get-caller-identity
   ```

   **Screenshot:** `task2_aws_get_caller_identity.png`

---

## Task 3 — Create Security Group and Ingress Rules

### Goal

Create a security group, allow SSH and HTTP from Codespace IP.

### Steps

1. **Create security group:**

   ```bash
   aws ec2 create-security-group \
     --group-name 'MySecurityGroup' \
     --description 'My Security Group' \
     --vpc-id vpc-EXAMPLE
   ```

   **Screenshot:** `task3_create_security_group_output.png`

2. **Describe security group (before rules):**

   ```bash
   aws ec2 describe-security-groups --group-ids sg-EXAMPLE
   ```

   **Screenshot:** `task3_describe_sg_before_ingress.png`

3. **Get Codespace public IP:**

   ```bash
   curl icanhazip.com
   ```

   **Screenshot:** `task3_codespace_public_ip.png`

4. **Authorize SSH (port 22):**

   ```bash
   aws ec2 authorize-security-group-ingress \
     --group-id sg-EXAMPLE \
     --protocol tcp \
     --port 22 \
     --cidr <YOUR_IP>/32
   ```

   **Screenshot:** `task3_authorize_ssh_and_describe.png`

5. **Authorize HTTP (port 80):**

   ```bash
   aws ec2 authorize-security-group-ingress \
     --group-id sg-EXAMPLE \
     --ip-permissions '{"FromPort":80,"ToPort":80,"IpProtocol":"tcp","IpRanges":[{"CidrIp":"<YOUR_IP>/32"}]}'
   ```

   **Screenshot:** `task3_authorize_http_and_describe.png`

6. **Final describe:**

   ```bash
   aws ec2 describe-security-groups --group-ids sg-EXAMPLE
   ```

   **Screenshot:** `task3_describe_sg_final.png`

---

## Task 4 — Key Pair and EC2 Instance

### Goal

Create ED25519 key pair and launch EC2 instance.

### Steps

1. **Create key pair:**

   ```bash
   aws ec2 create-key-pair \
     --key-name MyED25519Key \
     --key-type ed25519 \
     --key-format pem \
     --query 'KeyMaterial' \
     --output text > MyED25519Key.pem
   ls -l MyED25519Key.pem
   ```

   **Screenshot:** `task4_create_keypair_output.png`

2. **Describe key pairs:**

   ```bash
   aws ec2 describe-key-pairs
   ```

   **Screenshot:** `task4_describe_keypairs.png`

3. **Launch EC2 instance:**

   ```bash
   aws ec2 run-instances \
     --image-id ami-05e66df2bafcb7dea \
     --count 1 \
     --instance-type t3.micro \
     --key-name MyED25519Key \
     --security-group-ids sg-EXAMPLE \
     --subnet-id subnet-EXAMPLE \
     --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=MyServer}]"
   ```

   **Screenshot:** `task4_run_instances_output.png`

4. **Get public IP:**

   ```bash
   aws ec2 describe-instances \
     --query "Reservations[*].Instances[*].[InstanceId,PublicIpAddress]" \
     --output table
   ```

   **Screenshot:** `task4_describe_instances_public_ip.png`

5. **SSH into instance:**

   ```bash
   chmod 400 MyED25519Key.pem
   ssh -i MyED25519Key.pem ec2-user@<PUBLIC_IP>
   ```

   **Screenshot:** `task4_ssh_permission_error_and_fix.png`

---

## Task 5 — Describe Commands

Run and capture screenshots:

```bash
aws ec2 describe-security-groups
aws ec2 describe-vpcs
aws ec2 describe-subnets
aws ec2 describe-instances
aws ec2 describe-regions
aws ec2 describe-availability-zones
```

---

## Task 6 — IAM (Groups, Users, Policies)

Includes creating group/user, attaching policies, console login, access keys, and environment variable testing.

*(Commands exactly as provided in lab manual; screenshots required for each step.)*

---

## Task 7 — Filters

Use filters to query EC2 instances by tag, type, subnet, and VPC.

---

## Task 8 — Queries for Reporting

Use `--query` to format EC2 outputs into tables.

---

## Cleanup — Remove Resources

Terminate EC2 instances, delete key pairs, security groups, IAM users/groups, and verify no resources remain.

**Important:** Ensure AWS console shows no active resources to avoid charges.

