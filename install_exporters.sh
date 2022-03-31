#!/usr/bin/env bash

read -p "Enter token name, for example, ubld for Agoric: " TOKEN_NAME
read -p "Enter global prefix for addresses, for example, agoric for Agoric: " ADDRESS_PREFIX

echo '================================================='
echo -e "Token name: \e[1m\e[32m$TOKEN_NAME\e[0m"
echo -e "Address prefix: \e[1m\e[32m$ADDRESS_PREFIX\e[0m"
echo '================================================='
sleep 3

echo -e "\e[1m\e[32m1. Installing cosmos-exporter... \e[0m" && sleep 1
# install cosmos-exporter
wget https://github.com/solarlabsteam/cosmos-exporter/releases/download/v0.2.2/cosmos-exporter_0.2.2_Linux_x86_64.tar.gz
tar xvfz cosmos-exporter*
sudo cp ./cosmos-exporter /usr/bin
rm cosmos-exporter* -rf

sudo useradd -rs /bin/false cosmos_exporter

sudo tee <<EOF >/dev/null /etc/systemd/system/cosmos-exporter.service
[Unit]
Description=Cosmos Exporter
After=network-online.target

[Service]
User=cosmos_exporter
Group=cosmos_exporter
TimeoutStartSec=0
CPUWeight=95
IOWeight=95
ExecStart=cosmos-exporter --denom $TOKEN_NAME --denom-coefficient 1000000 --bech-prefix $ADDRESS_PREFIX
Restart=always
RestartSec=2
LimitNOFILE=800000
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable cosmos-exporter
sudo systemctl start cosmos-exporter

echo -e "\e[1m\e[32m2. Installing node-exporter... \e[0m" && sleep 1
# install node-exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar xvfz node_exporter-*.*-amd64.tar.gz
sudo mv node_exporter-*.*-amd64/node_exporter /usr/local/bin/
rm node_exporter-* -rf

sudo useradd -rs /bin/false node_exporter

sudo tee <<EOF >/dev/null /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start node_exporter

echo -e "\e[1m\e[32mInstallation finished... \e[0m" && sleep 1
echo -e "\e[1m\e[32mPlease make sure ports 9100 and 9500 are open \e[0m" && sleep 1
