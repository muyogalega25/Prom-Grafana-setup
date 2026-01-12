# Prometheus + Grafana + Alertmanager on AWS (Terraform)

This project provisions a complete monitoring stack on AWS using Terraform:
- Prometheus (metrics) + Alertmanager (alerts) on a dedicated EC2 instance
- Node Exporter on application servers + service discovery targets
- Grafana on a separate EC2 instance with Prometheus as a data source

## Architecture

- Prometheus/Alertmanager: Ubuntu 22.04, t2.micro
  - Inbound: 9090 (Prometheus), 9093 (Alertmanager), 22 (SSH)
- App servers (2): Ubuntu 22.04, t2.micro
  - Inbound: 9100 (Node Exporter), 22 (SSH)
- Service discovery targets (2): Ubuntu 22.04, t2.nano
  - Inbound: 9100 (Node Exporter), 22 (SSH)
- Grafana: Ubuntu 20.04, t2.micro
  - Inbound: 3000 (Grafana), 22 (SSH)

Prometheus uses EC2 Service Discovery (ec2_sd_configs) to automatically discover instances exposing Node Exporter on port 9100.

## Prerequisites

- AWS account + credentials configured locally (one of these):
  - 'aws configure'
  - or environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION)
- Terraform installed
- An existing EC2 Key Pair in your AWS account (for SSH)

## Quickstart

### 1) Clone repo and set variables

Create 'terraform.tfvars':

'''hcl
region       = "us-east-1"
key_name     = "YOUR_EC2_KEYPAIR_NAME"
allowed_ssh_cidr = "YOUR_PUBLIC_IP/32"
name_prefix  = "obs-lab"
