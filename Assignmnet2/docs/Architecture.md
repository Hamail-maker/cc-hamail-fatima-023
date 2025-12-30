\# Assignment 2 - Multi-Tier Web Infrastructure



\## Project Overview

This project implements a multi-tier web infrastructure on AWS using Terraform and Nginx. 

The architecture includes a load-balanced Nginx server with SSL/TLS, caching, and reverse proxy, 

serving multiple backend web servers with failover capability.

Architecture Diagram



Add a text-based diagram (or an image if you have one):



\## Architecture Diagram







\## Architecture Diagram



&nbsp;                         ┌───────────────┐

&nbsp;                         │   Internet    │

&nbsp;                         └───────┬───────┘

&nbsp;                                 │

&nbsp;                 ┌───────────────┴───────────────┐

&nbsp;                 │          Nginx Server        │

&nbsp;                 │       (Load Balancer)        │

&nbsp;                 │  - SSL/TLS Termination       │

&nbsp;                 │  - Reverse Proxy             │

&nbsp;                 │  - Caching                   │

&nbsp;                 │  - Rate Limiting             │

&nbsp;                 └───────────────┬───────────────┘

&nbsp;                                 │

&nbsp;         ┌───────────────┬───────────────┬───────────────┐

&nbsp;         │               │               │

&nbsp;         ▼               ▼               ▼

&nbsp;     ┌───────┐       ┌───────┐       ┌────────┐

&nbsp;     │ Web-1 │       │ Web-2 │       │ Web-3  │

&nbsp;     │Primary│       │Primary│       │Backup  │

&nbsp;     └───────┘       └───────┘       └────────┘

&nbsp;         │               │               │

&nbsp;         └───────┬───────┴───────┬───────┘

&nbsp;                 │               │

&nbsp;                 ▼               ▼

&nbsp;        ┌─────────────────────────────┐

&nbsp;        │  Health Check Scripts       │

&nbsp;        │  - Monitor backend servers  │

&nbsp;        │  - Log UP/DOWN status      │

&nbsp;        │  - Alert on failure        │

&nbsp;        └─────────────┬─────────────┘

&nbsp;                      │

&nbsp;                      ▼

&nbsp;            ┌────────────────┐

&nbsp;            │ Health Logs    │

&nbsp;            │ (health\_log.txt)│

&nbsp;            └────────────────┘



Legend:

\- Web-1 \& Web-2: Primary backend servers

\- Web-3: Backup server

\- Nginx: Load balancer handling HTTPS, caching, reverse proxy, and rate limiting

\- Health Check Scripts: Monitor server health and log status





---



\### \*\*C. Components Description\*\*



\- List main components and their roles:



```markdown

\## Components Description



\- \*\*Nginx Server\*\*: Load balancer, SSL termination, caching, reverse proxy

\- \*\*Web-1 \& Web-2\*\*: Primary backend servers

\- \*\*Web-3\*\*: Backup server

\- \*\*Terraform\*\*: Infrastructure provisioning

\- \*\*Health Check Scripts\*\*: Monitors backend servers and logs status



D. Prerequisites



List all required tools and credentials:



\## Prerequisites



\- \*\*Required Tools\*\*:

&nbsp; - Terraform

&nbsp; - AWS CLI

&nbsp; - Nginx

&nbsp; - PowerShell or Bash (for scripts)



\- \*\*AWS Credentials Setup\*\*:

&nbsp; - Configure AWS CLI with `aws configure`

&nbsp; - Store Access Key ID and Secret Access Key securely



\- \*\*SSH Key Setup\*\*:

&nbsp; - Generate a key pair for EC2 instances

&nbsp; - Add the public key in AWS and private key to local machine

Deployment Instructions

\## Deployment Instructions



1\. Configure variables in `variables.tf`

2\. Run Terraform commands:

&nbsp;  ```bash

&nbsp;  D:\\terraform\_1.14.3\_windows\_amd64\\terraform.exe init

&nbsp;  D:\\terraform\_1.14.3\_windows\_amd64\\terraform.exe plan

&nbsp;  D:\\terraform\_1.14.3\_windows\_amd64\\terraform.exe apply -auto-approve
   D:\\terraform\_1.14.3\_windows\_amd64\\terraform.exe validate



Verify backend IPs and Nginx config



Ensure health check scripts are running





---



\### \*\*F. Configuration Guide\*\*



```markdown

\## Configuration Guide



\- \*\*Updating Backend IPs\*\*:

&nbsp; - Edit the upstream block in Nginx config

&nbsp; - Update `BACKENDS` array in health check scripts



\- \*\*Nginx Configuration Explanation\*\*:

&nbsp; - SSL/TLS: Terminates HTTPS traffic

&nbsp; - Caching: Reduces load on backend servers

&nbsp; - Rate Limiting: Prevents request abuse

&nbsp; - Reverse Proxy: Forwards requests to backend servers



\- \*\*Testing Procedures\*\*:

&nbsp; - Test rate limiting with `curl` or `ab`

&nbsp; - Test health check by stopping a backend server temporarily



G. Architecture Details

\## Architecture Details



\- \*\*Network Topology\*\*:

&nbsp; - Internet → Nginx (LB) → Web-1 \& Web-2 (Primary) → Web-3 (Backup)

\- \*\*Security Groups Explanation\*\*:

&nbsp; - Nginx SG: Allow HTTP/HTTPS from anywhere

&nbsp; - Backend SG: Allow traffic only from Nginx SG

\- \*\*Load Balancing Strategy\*\*:

&nbsp; - Round-robin with failover using Web-3 as backup



H. Troubleshooting

\## Troubleshooting



\- \*\*Common Issues\*\*:

&nbsp; - Nginx fails to start → check syntax: `nginx -t`

&nbsp; - Health check script not logging → check `$HOME\\health\_check\\health\_log.txt`

\- \*\*Log Locations\*\*:

&nbsp; - Nginx logs: `/var/log/nginx/access.log` \& `error.log`

&nbsp; - Health Check: `health\_log.txt`

\- \*\*Debug Commands\*\*:

&nbsp; - Restart Nginx: `nginx -s reload`

&nbsp; - Tail logs: `tail -f access.log`

