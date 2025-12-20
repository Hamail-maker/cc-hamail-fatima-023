
# Cloud Computing Lab 11 — Terraform Variables & AWS Infrastructure

## Student Information

* **Name:** Hamail Fatima
* **Lab:** 11
* **Course:** Cloud Computing
* **Tooling:** Terraform, AWS, GitHub Codespaces

---

## Objective

The objective of this lab is to understand **Terraform variables, locals, outputs, collections, null & dynamic values**, and then **build real AWS infrastructure** including a **VPC, Subnet, Internet Gateway, Routing, Security Groups, EC2, SSH keys, and nginx**.
Finally, all resources are cleaned up to avoid charges.

---

## Task 1 — Environment Variables in Terraform

### Description

Terraform supports passing variables using environment variables prefixed with `TF_VAR_`.

### Steps

```bash
export TF_VAR_subnet_cidr_block=10.0.20.0/24
terraform apply -auto-approve
```

### Expected Output

Terraform apply output should reflect the subnet CIDR value coming from the environment variable.

📸 **Screenshot:** `task1_env_var_set_and_apply.png`

---

## Task 3 — Project-level Variables, Locals & Outputs

### Variables Added (main.tf)

```hcl
variable "environment" {}
variable "project_name" {}
variable "primary_subnet_id" {}
variable "subnet_count" {}
variable "monitoring" {}
```

📸 `task3_variables_added.png`

---

### Populate `terraform.tfvars`

```hcl
environment        = "dev"
project_name       = "lab_work"
primary_subnet_id  = "<subnet-id>"
subnet_count       = 3
monitoring         = true
```

📸 `task3_terraform_tfvars_populated.png`

---

### Locals (locals.tf)

```hcl
locals {
  resource_name        = "${var.project_name}-${var.environment}"
  primary_public_subnet = var.primary_subnet_id
  subnet_count          = var.subnet_count
  is_production         = var.environment == "prod"
  monitoring_enabled    = var.monitoring || local.is_production
}
```

📸 `task3_locals_tf_created.png`

---

### Outputs

```hcl
output "resource_name" {
  value = local.resource_name
}
```

📸 `task3_outputs_apply.png`

---

## Task 4 — Maps & Objects

### Map Variable

```hcl
variable "tags" {
  type = map(string)
}
```

```hcl
tags = {
  Environment = "dev"
  Project     = "sample-app"
  Owner       = "platform-team"
}
```

📸 `task4_tags_output.png`

---

### Object Variable

```hcl
variable "server_config" {
  type = object({
    name           = string
    instance_type  = string
    monitoring     = bool
    storage_gb     = number
    backup_enabled = bool
  })
}
```

📸 `task4_server_config_output.png`

---

## Task 5 — Collections (List, Tuple, Set)

### Defined Collections

```hcl
variable "server_names" {
  type    = list(string)
  default = ["web-2", "web-1", "web-2"]
}

variable "server_metadata" {
  type    = tuple([string, number, bool])
  default = ["web-1", 4, true]
}

variable "availability_zones" {
  type    = set(string)
  default = ["me-central-1b", "me-central-1a", "me-central-1b"]
}
```

📸 `task5_compare_collections.png`

---

### Mutation via Locals

```hcl
locals {
  mutated_list  = setunion(var.server_names, ["web-3"])
  mutated_tuple = setunion(var.server_metadata, ["web-2"])
  mutated_set   = setunion(var.availability_zones, ["me-central-1c"])
}
```

📸 `task5_mutation_comparison.png`

---

## Task 6 — Null & Any Type Variables

### Optional Variable

```hcl
variable "optional_tag" {
  type    = string
  default = null
}
```

📸 `task6_optional_tag_no_value.png`
📸 `task6_optional_tag_with_value.png`

---

### Any Type Variable

```hcl
variable "dynamic_value" {
  type = any
}
```

Tested with:

* String
* Number
* List
* Map
* Null

📸 Screenshots from `task6_dynamic_value_*`

---

## Task 7 — Git Ignore

### `.gitignore`

```gitignore
.terraform/*
*.tfstate
*.tfstate.*
*.tfvars
*.pem
```

📸 `task7_gitignore_created.png`

---

## Task 8 — Build Real Infrastructure

### Resources Created

* VPC
* Subnet
* Internet Gateway
* Default Route Table

📸 `task8_vpc_subnet_apply.png`
📸 `task8_default_route_table_apply.png`

---

## Task 9 — Security Group, EC2, SSH & Nginx

### Security Group

* SSH (22) — My IP
* HTTP (80) — Public

📸 `task9_security_group_apply.png`

---

### EC2 Instance

* Amazon Linux 2023
* Public IP enabled
* SSH key authentication

📸 `task9_ec2_apply_and_public_ip.png`

---

### Nginx via `user_data`

```bash
#!/bin/bash
yum update -y
yum install -y nginx
systemctl start nginx
systemctl enable nginx
```

📸 `task9_nginx_local_curl.png`
📸 `task9_nginx_browser_page.png`

---

## Cleanup

### Destroy Resources

```bash
terraform destroy -auto-approve
```

📸 `cleanup_destroy.png`

---

### Verify State Files

```bash
cat terraform.tfstate
cat terraform.tfstate.backup
```

📸 `cleanup_state_files.png`

---

### Verify No Secrets

```bash
git status
```

📸 `cleanup_verify_no_secrets.png`

---

