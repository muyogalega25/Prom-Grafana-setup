# -----------------------------
# Default VPC + Subnets
# -----------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  # Pick the first subnet in the default VPC (simple lab choice)
  subnet_id = tolist(data.aws_subnets.default.ids)[0]
}

# -----------------------------
# AMIs
# -----------------------------
# Ubuntu 22.04 (Jammy) AMI
data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Ubuntu 20.04 (Focal) AMI for Grafana
data "aws_ami" "ubuntu_2004" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -----------------------------
# EC2 Instances
# Note: security groups and IAM instance profile must exist:
# - aws_security_group.prometheus_sg
# - aws_security_group.node_exporter_sg
# - aws_security_group.grafana_sg
# - aws_iam_instance_profile.prometheus_profile
# -----------------------------

# Prometheus server
resource "aws_instance" "prometheus" {
  ami                  = data.aws_ami.ubuntu_2204.id
  instance_type        = var.prometheus_instance_type
  subnet_id            = local.subnet_id
  key_name             = var.key_name
  iam_instance_profile = aws_iam_instance_profile.prometheus_profile.name

  vpc_security_group_ids = [
    aws_security_group.prometheus_sg.id
  ]

  user_data = templatefile("${path.module}/user_data/prometheus.sh", {
    repo_url    = var.repo_url
    repo_folder = var.repo_folder
    aws_region  = var.aws_region
  })

  tags = {
    Name    = "${var.project_name}-prometheus"
    Project = var.project_name
    Role    = "prometheus"
  }
}

# Two app servers with node exporter
resource "aws_instance" "app" {
  count         = 2
  ami           = data.aws_ami.ubuntu_2204.id
  instance_type = var.app_instance_type
  subnet_id     = local.subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.node_exporter_sg.id
  ]

  user_data = templatefile("${path.module}/user_data/node_exporter.sh", {
    repo_url    = var.repo_url
    repo_folder = var.repo_folder
  })

  tags = {
    Name    = "${var.project_name}-app-${count.index + 1}"
    Project = var.project_name
    Role    = "app"
  }
}

# Two servers to prove EC2 service discovery on port 9100
resource "aws_instance" "sd" {
  count         = 2
  ami           = data.aws_ami.ubuntu_2204.id
  instance_type = var.sd_instance_type
  subnet_id     = local.subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.node_exporter_sg.id
  ]

  user_data = templatefile("${path.module}/user_data/node_exporter.sh", {
    repo_url    = var.repo_url
    repo_folder = var.repo_folder
  })

  tags = {
    Name    = "${var.project_name}-sd-${count.index + 1}"
    Project = var.project_name
    Role    = "sd-node"
  }
}

# Grafana server
resource "aws_instance" "grafana" {
  ami           = data.aws_ami.ubuntu_2004.id
  instance_type = var.grafana_instance_type
  subnet_id     = local.subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.grafana_sg.id
  ]

  user_data = templatefile("${path.module}/user_data/grafana.sh", {
    repo_url    = var.repo_url
    repo_folder = var.repo_folder
  })

  tags = {
    Name    = "${var.project_name}-grafana"
    Project = var.project_name
    Role    = "grafana"
  }
}
