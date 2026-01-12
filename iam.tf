# iam.tf : Prometheus must query AWS APIs to discover EC2 instances.
# iam.tf
# Prometheus must query AWS APIs to discover EC2 instances via EC2 service discovery.

# -----------------------------
# IAM Role for Prometheus
# -----------------------------
resource "aws_iam_role" "prometheus_role" {
  name = "${var.project_name}-prometheus-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Project = var.project_name
  }
}

# -----------------------------
# Inline policy: allow EC2 service discovery
# -----------------------------
resource "aws_iam_role_policy" "prometheus_describe_instances" {
  name = "${var.project_name}-prometheus-describe-instances"
  role = aws_iam_role.prometheus_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowEC2ServiceDiscovery"
      Effect = "Allow"
      Action = [
        "ec2:DescribeInstances",
        "ec2:DescribeRegions",
        "ec2:DescribeTags"
      ]
      Resource = "*"
    }]
  })
}

# -----------------------------
# Instance profile attached to Prometheus EC2
# -----------------------------
resource "aws_iam_instance_profile" "prometheus_profile" {
  name = "${var.project_name}-prometheus-profile"
  role = aws_iam_role.prometheus_role.name
}
