# Instructions

## Prerequisites
run script below to prepare your monitroring node
```
wget -O install_monitoring.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/monitoring/install_monitoring.sh && chmod +x install_monitoring.sh && ./install_monitoring.sh
```

## Deployment

### copy _.env.example_ into _.env_
```
cp $HOME/cosmos_node_monitoring/config/.env.example $HOME/cosmos_node_monitoring/config/.env
```

### add values in _.env_ file
```
vim $HOME/cosmos_node_monitoring/config/.env
```

### export _.env_ file values
```
export $(xargs < $HOME/cosmos_node_monitoring/config/.env)
```

### update _prometheus_ configuration file
```
sed -i 's/VALIDATOR_IP/$VALIDATOR_IP/g' $HOME/cosmos_node_monitoring/prometheus/prometheus.yml
sed -i 's/VALOPER_ADDRESS/$VALOPER_ADDRESS/g' $HOME/cosmos_node_monitoring/prometheus/prometheus.yml
sed -i 's/WALLET_ADDRESS/$WALLET_ADDRESS/g' $HOME/cosmos_node_monitoring/prometheus/prometheus.yml
```

### start the contrainers
Deploy the monitoring stack (Grafana + Prometheus + Node Exporter)
```
cd $HOME/cosmos_node_monitoring
docker compose --profile monitor up -d --env-file ./config/.env
```

Deploy the monitor stack and the alerting stack (alert manager + alerta + telegram bot)
```
cd $HOME/cosmos_node_monitoring
docker compose --profile alert up -d --env-file ./config/.env
```

## Firewall Rules
make sure the following ports are open:

- `8080` (telegram bot)
- `9090` (prometheus)
- `9093` (alert manager)
- `9100` (node exporter)
- `9999` (grafana)

## Install cosmos-exporter
get latest release of node-exporter -> [releases page](https://github.com/solarlabsteam/cosmos-exporter/releases)
* CHAIN_TOKEN_NAME - the currency, for example, uatom for Cosmos.
* ADDRESS_PREFIX - the global prefix for addresses, for example, cosmos for Cosmos.
	
```
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
ExecStart=cosmos-exporter --denom <CHAIN_TOKEN_NAME> --denom-coefficient 1000000 --bech-prefix <ADDRESS_PREFIX>
Restart=always
RestartSec=2
LimitNOFILE=800000
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable cosmos-exporter
sudo systemctl start cosmos-exporter
sudo systemctl status cosmos-exporter
```

allow 9500 cosmos-exporter port
```
sudo ufw allow 9500
```

## Install node-exporter
get latest release of node-exporter -> [releases page](https://github.com/prometheus/node_exporter/releases)
```
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
sudo systemctl status node_exporter
```

allow 9100 node-exporter port
```
sudo ufw allow 9100
```
