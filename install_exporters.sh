#!/usr/bin/env bash

if [ ! $TOKEN_NAME ]; then
	read -p "Enter token name, for example, uatom for Cosmos: " TOKEN_NAME
	echo 'export TOKEN_NAME='$TOKEN_NAME >> $HOME/.bash_profile
	. ~/.bash_profile
fi

if [ ! $ADDRESS_PREFIX ]; then
	read -p "Enter global prefix for addresses, for example, cosmos for Cosmos: " ADDRESS_PREFIX
	echo 'export ADDRESS_PREFIX='$ADDRESS_PREFIX >> $HOME/.bash_profile
	. ~/.bash_profile
fi

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

# check status
sudo systemctl status cosmos-exporter
sudo systemctl status node_exporter
