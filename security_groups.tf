# security_groups.tf : explicitly exposes only required ports


# -----------------------------
# Prometheus SG
# -----------------------------
resource "aws_security_group" "prometheus_sg" {
  name        = "${var.project_name}-prometheus-sg"
  description = "Prometheus + Alertmanager inbound"
  vpc_id      = data.aws_vpc.default.id

  # SSH (restricted)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Prometheus UI (restricted)
  ingress {
    description = "Prometheus UI"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = var.ui_cidr_blocks
  }

  # Alertmanager UI (restricted)
  ingress {
    description = "Alertmanager UI"
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = var.ui_cidr_blocks
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-prometheus-sg"
    Project = var.project_name
  }
}

# -----------------------------
# Node Exporter SG (targets)
# -----------------------------
resource "aws_security_group" "node_exporter_sg" {
  name        = "${var.project_name}-node-exporter-sg"
  description = "Node Exporter targets (9100) + restricted SSH"
  vpc_id      = data.aws_vpc.default.id

  # SSH (restricted)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Node Exporter: ONLY allow Prometheus to scrape
  ingress {
    description     = "Node Exporter scrape from Prometheus SG"
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    security_groups = [aws_security_group.prometheus_sg.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-node-exporter-sg"
    Project = var.project_name
  }
}

# -----------------------------
# Grafana SG
# -----------------------------
resource "aws_security_group" "grafana_sg" {
  name        = "${var.project_name}-grafana-sg"
  description = "Grafana inbound"
  vpc_id      = data.aws_vpc.default.id

  # SSH (restricted)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Grafana UI (restricted)
  ingress {
    description = "Grafana UI"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.ui_cidr_blocks
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-grafana-sg"
    Project = var.project_name
  }
}

