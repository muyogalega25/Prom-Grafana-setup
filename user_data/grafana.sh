#!/bin/bash
set -e

sudo apt-get update -y
sudo apt-get install git -y

cd /home/ubuntu
if [ ! -d "${repo_folder}" ]; then
  sudo -u ubuntu git clone ${repo_url}
fi

cd /home/ubuntu/prometheus-grafana-setups || true
sudo sh install-grafana.sh

sudo systemctl restart grafana-server.service
sudo systemctl status grafana-server.service --no-pager || true
