variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "key_name" {
  type        = string
  description = "ec2-jenkins-cicd"
}

variable "project_name" {
  type    = string
  default = "observability-stack"
}

variable "prometheus_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "app_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "sd_instance_type" {
  type    = string
  default = "t2.nano"
}

variable "grafana_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "allowed_ssh_cidr" {
  type        = string
  description = " 0.0.0.0/0"
}

variable "repo_url" {
  type    = string
  default = "https://github.com/muyogalega25/Prom-Grafana-setup.git"
}

variable "repo_folder" {
  type    = string
  default = "Prom-Grafana-setup"
}
