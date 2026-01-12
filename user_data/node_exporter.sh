#!/bin/bash
set -e

# Update packages
sudo apt-get update -y

# Install git
sudo apt-get install git -y

# Clone repo
cd /home/ubuntu
if [ ! -d "${repo_folder}" ]; then
  sudo -u ubuntu git clone ${repo_url}
fi

# Navigate to setup folder (matches your instructions)
cd /home/ubuntu/${repo_folder}
cd /home/ubuntu/prometheus-grafana-setups || true

# Install Node Exporter (your exact step)
sudo sh install-node-exporter.sh

# Confirm service
sudo systemctl status node_exporter.service --no-pager || true
