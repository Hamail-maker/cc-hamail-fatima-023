# Nginx and HTTPD High Availability Lab

This project sets up a high availability architecture using Nginx as a frontend load balancer and three Apache HTTPD servers as backend servers. The infrastructure is provisioned using Terraform, and the configuration of the servers is managed with Ansible.

## Project Structure

- **terraform/**: Contains Terraform configuration files to provision the necessary infrastructure.
  - **main.tf**: Defines the main infrastructure resources, including VPC, subnets, security groups, and EC2 instances.
  - **variables.tf**: Declares input variables for customization of the infrastructure.
  - **outputs.tf**: Specifies the outputs of the Terraform configuration.
  - **terraform.tfvars**: Contains values for the variables defined in `variables.tf`.

- **ansible/**: Contains Ansible playbooks and roles for configuring the servers.
  - **inventory.ini**: Static inventory listing the frontend and backend servers with their IP addresses.
  - **playbook.yml**: Main Ansible playbook orchestrating the configuration of the servers.
  - **roles/**: Contains roles for Nginx frontend and HTTPD backend.
    - **nginx-frontend/**: Role for configuring the Nginx frontend.
      - **tasks/**: Contains tasks for installing and configuring Nginx.
      - **templates/**: Jinja2 template for Nginx configuration.
      - **handlers/**: Handlers for managing Nginx service.
      - **vars/**: Variables specific to the Nginx role.
    - **httpd-backend/**: Role for configuring the HTTPD backend.
      - **tasks/**: Contains tasks for installing and configuring HTTPD.
      - **templates/**: Jinja2 template for HTTPD configuration.
      - **handlers/**: Handlers for managing HTTPD service.
      - **vars/**: Variables specific to the HTTPD role.

## Setup Instructions

1. **Terraform Configuration**:
   - Navigate to the `terraform` directory.
   - Customize the `terraform.tfvars` file with your desired values.
   - Run `terraform init` to initialize the Terraform configuration.
   - Run `terraform apply` to provision the infrastructure.

2. **Ansible Configuration**:
   - Navigate to the `ansible` directory.
   - Update the `inventory.ini` file with the IP addresses of the provisioned servers.
   - Run `ansible-playbook playbook.yml` to configure the servers.

## Assumptions

- AWS is used as the cloud provider for provisioning the infrastructure.
- The necessary IAM permissions are available for creating resources.
- SSH access is configured for the EC2 instances.

This project provides a scalable and resilient architecture suitable for web applications requiring load balancing and high availability.