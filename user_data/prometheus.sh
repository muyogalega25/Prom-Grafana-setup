# This installs Prometheus, Alertmanager, and configures EC2 service discovery.
#!/bin/bash
set -e

sudo apt-get update -y
sudo apt-get install git -y

# Clone repo
cd /home/ubuntu
if [ ! -d "${repo_folder}" ]; then
  sudo -u ubuntu git clone ${repo_url}
fi

# Prometheus install path per your instructions
cd /home/ubuntu/prometheus-grafana-setups || true
sudo sh install-prometheus.sh

# Replace Prometheus config to enable EC2 service discovery on port 9100
# This matches the prometheus_service Discovery.yml content you provided.
sudo tee /etc/prometheus/prometheus.yml > /dev/null <<EOF
global:
  scrape_interval: 15s
  external_labels:
    monitor: 'prometheus'

scrape_configs:
  - job_name: 'node'
    ec2_sd_configs:
      - region: ${aws_region}
        port: 9100
EOF

# Restart Prometheus
sudo systemctl restart prometheus.service
sudo systemctl status prometheus.service --no-pager || true

# Install Alertmanager using repo script
# If your repo uses a different folder name, adjust here.
cd /home/ubuntu/prometheus-grafana-setups || true
sudo sh install-alertmanager.sh || true

# Restart Alertmanager if installed
sudo systemctl restart alertmanager.service || true
sudo systemctl status alertmanager.service --no-pager || true
