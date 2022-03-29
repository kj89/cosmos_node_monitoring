# Instructions

## Prerequisites

### Install exporters on validator node
First of all you will have to install exporters on validator node. For that you can use one-liner below
```
wget -O install_exporters.sh https://raw.githubusercontent.com/kj89/cosmos_node_monitoring/master/install_exporters.sh && chmod +x install_exporters.sh && ./install_exporters.sh
```
make sure following ports are open:
- `9100` (node-exporter)
- `9500` (cosmos-exporter)

## Deployment

### System requirements
Ubuntu 20.04 / 1 VCPU / 2 GB RAM / 20 GB SSD

### Install monitoring stack
To install monitirng stack you can use one-liner below
```
wget -O install_monitoring.sh https://raw.githubusercontent.com/kj89/cosmos_node_monitoring/master/install_monitoring.sh && chmod +x install_monitoring.sh && ./install_monitoring.sh
```

### Copy _.env.example_ into _.env_
```
cp $HOME/cosmos_node_monitoring/config/.env.example $HOME/cosmos_node_monitoring/config/.env
```

### Update values in _.env_ file
```
vim $HOME/cosmos_node_monitoring/config/.env
```

| KEY | VALUE |
|---------------|-------------|
| VALIDATOR_IP | Public ip address of you validator |
| VALOPER_ADDRESS | Operator address of your validator, for example, _"agoricvaloper1zyyz4m9ytdf60fn9yaafx7uy7h463n7alv2ete"_ |
| WALLET_ADDRESS | Your validator self-deligate wallet address, for example, _"agoric1zyyz4m9ytdf60fn9yaafx7uy7h463n7a05eshc"_ |
| TELEGRAM_ADMIN | Your user id you can get from [@userinfobot](https://t.me/userinfobot). The bot will only reply to messages sent from the user. All other messages are dropped and logged on the bot's console |
| TELEGRAM_TOKEN | Your telegram bot access token you can get from [@botfather](https://telegram.me/botfather). To generate new token just follow a few simple steps described [here](https://core.telegram.org/bots#6-botfather) |

### Export _.env_ file values
```
export $(xargs < $HOME/cosmos_node_monitoring/config/.env)
```

### Update _prometheus_ configuration file
```
sed -i "s/VALIDATOR_IP/$VALIDATOR_IP/g" $HOME/cosmos_node_monitoring/prometheus/prometheus.yml
sed -i "s/VALOPER_ADDRESS/$VALOPER_ADDRESS/g" $HOME/cosmos_node_monitoring/prometheus/prometheus.yml
sed -i "s/WALLET_ADDRESS/$WALLET_ADDRESS/g" $HOME/cosmos_node_monitoring/prometheus/prometheus.yml
```

### Run docker compose
Deploy the monitoring stack
```
cd $HOME/cosmos_node_monitoring
docker compose up -d
```

### Configure grafana
1. Open Grafana in your web browser
2. Change admin password. Defaults are `admin/admin`
3. Import custom dashboard
