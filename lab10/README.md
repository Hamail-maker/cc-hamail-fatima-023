# Cloud Computing Lab 10

**Course:** Cloud Computing
**Submitted To:** Sir Shoaib & Sir Waqas
**Submitted By:** Hamail Fatima
**Roll No:** 2023-BSE-023
**Section:** 5(A)

---

## Task 1 — GitHub CLI Codespace Setup & Authentication

### Goal

Install GitHub CLI (if not present), authenticate for Codespaces, and connect to a Codespace shell.

### Steps

#### 1. Install GitHub CLI (Local Machine)

```bash
winget install --id GitHub.cli
```

📸 **Screenshot:** `task1_gh_install.png`

#### 2. Authenticate GitHub CLI

```bash
gh auth login -s codespace
```

* Generate **GitHub access token (classic)**
* Scopes:

  * `admin:org`
  * `codespace`
  * `repo`

📸 **Screenshot:** `task1_gh_auth_login.png`

#### 3. List Codespaces

```bash
gh codespace list
```

📸 **Screenshot:** `task1_codespace_list.png`

#### 4. Connect to Codespace via SSH

```bash
gh codespace ssh -c <name_of_codespace>
```

📸 **Screenshot:** `task1_codespace_ssh_connected.png`

---

## Task 2 — Install AWS CLI, Terraform CLI & Provider Setup

### A. Install AWS CLI (Inside Codespace)

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

📸 **Screenshot:** `task2_aws_install_and_version.png`

#### Configure AWS CLI

```bash
aws configure
```

```bash
cat ~/.aws/credentials
cat ~/.aws/config
```

📸 **Screenshot:** `task2_aws_configure_and_files.png`

#### Verify AWS Access

```bash
aws sts get-caller-identity
```

📸 **Screenshot:** `task2_aws_get_caller_identity.png`

---

### B. Install Terraform CLI

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install terraform
which terraform
terraform --version
```

📸 **Screenshot:** `task2_terraform_install_and_version.png`

---

### C. Provider Configuration

```bash
vim main.tf
```

📸 **Screenshot:** `task2_provider_file_creation.png`

```hcl
provider "aws" {
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
}
```

📸 **Screenshot:** `task2_provider_block.png`

```bash
terraform init
```

📸 **Screenshot:** `task2_terraform_init_output.png`

```bash
cat .terraform.lock.hcl
ls .terraform/
```

📸 **Screenshots:**

* `task2_terraform_lock_hcl.png`
* `task2_terraform_dir_ls.png`

---

## Task 3 — VPC & Subnet Creation

```hcl
resource "aws_vpc" "development_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "dev_subnet_1" {
  vpc_id            = aws_vpc.development_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "me-central-1a"
}
```

📸 **Screenshot:** `task3_main_tf_resource_add.png`

```bash
terraform apply
```

📸 **Screenshot:** `task3_terraform_apply_vpc_subnet.png`

```bash
aws ec2 describe-subnets --filter "Name=subnet-id,Values=<subnet-id>"
aws ec2 describe-vpcs --filter "Name=vpc-id,Values=<vpc-id>"
```

📸 **Screenshots:**

* `task3_aws_cli_verify_subnet.png`
* `task3_aws_cli_verify_vpc.png`

---

## Task 4 — Data Source, Targeted Destroy & Tags

### A. Data Source & Resource

```hcl
data "aws_vpc" "existing_vpc" {
  default = true
}

resource "aws_subnet" "dev_subnet_1_existing" {
  vpc_id            = data.aws_vpc.existing_vpc.id
  cidr_block        = "172.31.48.0/24"
  availability_zone = "me-central-1a"
}
```

📸 **Screenshot:** `task4_main_tf_datasource_resource_add.png`

```bash
terraform apply
```

📸 **Screenshot:** `task4_terraform_apply_datasource_resource.png`

---

### B. Targeted Destroy & Refresh

```bash
terraform destroy -target=aws_subnet.dev_subnet_1_existing
terraform refresh
terraform apply
terraform destroy
terraform plan
terraform apply
```

📸 **Screenshots:**

* `task4_terraform_destroy_targeted.png`
* `task4_terraform_refresh_state.png`
* `task4_terraform_apply_after_refresh.png`
* `task4_terraform_destroy_all.png`
* `task4_terraform_plan_output.png`
* `task4_terraform_apply_after_destroy.png`

---

### C. Tagging Resources

```hcl
resource "aws_vpc" "development_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name    = "development"
    vpc_env = "dev"
  }
}
```

```hcl
resource "aws_subnet" "dev_subnet_1" {
  vpc_id            = aws_vpc.development_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "me-central-1a"
  tags = {
    Name = "subnet-1-dev"
  }
}
```

```hcl
resource "aws_subnet" "dev_subnet_1_existing" {
  vpc_id            = data.aws_vpc.existing_vpc.id
  cidr_block        = "172.31.48.0/24"
  availability_zone = "me-central-1a"
  tags = {
    Name = "subnet-1-default"
  }
}
```

📸 **Screenshot:** `task4_main_tf_tagging.png`

```bash
terraform refresh
terraform apply -auto-approve
```

📸 **Screenshot:** `task4_terraform_apply_tagging.png`

Remove `vpc_env` tag, then:

```bash
terraform plan
terraform apply
```

📸 **Screenshots:**

* `task4_terraform_plan_remove_tag.png`
* `task4_terraform_apply_remove_tag.png`

---

## Task 5 — Terraform State Inspection

```bash
terraform destroy
```

📸 **Screenshot:** `task5_terraform_destroy.png`

```bash
cat terraform.tfstate
cat terraform.tfstate.backup
```

📸 **Screenshots:**

* `task5_terraform_state_file_empty.png`
* `task5_terraform_state_backup_prev.png`

```bash
terraform apply
```

📸 **Screenshot:** `task5_terraform_apply_recreated.png`

```bash
cat terraform.tfstate
cat terraform.tfstate.backup
terraform state list
terraform state show <resource-name>
```

📸 **Screenshots:**

* `task5_terraform_state_file_populated.png`
* `task5_terraform_state_backup_empty.png`
* `task5_terraform_state_list.png`
* `task5_terraform_state_show_resource.png`

> ⚠️ **Do NOT run:** `terraform state rm <resource-name>` (theory only)

---

## Task 6 — Terraform Outputs & Attributes

### Basic Outputs

```hcl
output "dev-vpc-id" { value = aws_vpc.development_vpc.id }
output "dev-subnet-id" { value = aws_subnet.dev_subnet_1.id }
output "dev-vpc-arn" { value = aws_vpc.development_vpc.arn }
output "dev-subnet-arn" { value = aws_subnet.dev_subnet_1.arn }
```

📸 **Screenshot:** `task6_terraform_outputs_basic.png`

### Expanded Outputs

```hcl
output "dev-vpc-cidr_block" { value = aws_vpc.development_vpc.cidr_block }
output "dev-vpc-region" { value = aws_vpc.development_vpc.region }
output "dev-vpc-tags_name" { value = aws_vpc.development_vpc.tags["Name"] }
output "dev-vpc-tags_all" { value = aws_vpc.development_vpc.tags_all }

output "dev-subnet-cidr_block" { value = aws_subnet.dev_subnet_1.cidr_block }
output "dev-subnet-region" { value = aws_subnet.dev_subnet_1.availability_zone }
output "dev-subnet-tags_name" { value = aws_subnet.dev_subnet_1.tags["Name"] }
output "dev-subnet-tags_all" { value = aws_subnet.dev_subnet_1.tags_all }
```

```bash
terraform apply
```

📸 **Screenshot:** `task6_expanded_outputs.png`

---

## Cleanup — Final Verification

```bash
terraform destroy
cat terraform.tfstate
cat terraform.tfstate.backup
```

📸 **Screenshots:**

* `cleanup_destroy_resources.png`
* `cleanup_state_files.png`

---

### ✅ End of Lab
