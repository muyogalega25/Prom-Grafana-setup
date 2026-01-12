output "prometheus_public_url" {
  value = "http://${aws_instance.prometheus.public_ip}:9090"
}

output "alertmanager_public_url" {
  value = "http://${aws_instance.prometheus.public_ip}:9093"
}

output "grafana_public_url" {
  value = "http://${aws_instance.grafana.public_ip}:3000"
}

output "app_private_ips" {
  value = [for i in aws_instance.app : i.private_ip]
}

output "sd_private_ips" {
  value = [for i in aws_instance.sd : i.private_ip]
}
