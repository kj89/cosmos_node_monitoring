# Instructions

## Prerequisites

### run on validtor node
install exporters on validator node
```
wget -O install_exporters.sh https://raw.githubusercontent.com/kj89/cosmos_node_monitoring/master/install_exporters.sh && chmod +x install_exporters.sh && ./install_exporters.sh
```
make sure following ports are open:
- `9100` (node-exporter)
- `9500` (cosmos-exporter)

### run on monitoring node
install monitoring stack on monitoring node
```
wget -O install_monitoring.sh https://raw.githubusercontent.com/kj89/cosmos_node_monitoring/master/install_monitoring.sh && chmod +x install_monitoring.sh && ./install_monitoring.sh
```
make sure following ports are open:
- `8080` (telegram bot)
- `9090` (prometheus)
- `9093` (alert manager)
- `9999` (grafana)

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
sed -i "s/VALIDATOR_IP/$VALIDATOR_IP/g" $HOME/cosmos_node_monitoring/prometheus/prometheus.yml
sed -i "s/VALOPER_ADDRESS/$VALOPER_ADDRESS/g" $HOME/cosmos_node_monitoring/prometheus/prometheus.yml
sed -i "s/WALLET_ADDRESS/$WALLET_ADDRESS/g" $HOME/cosmos_node_monitoring/prometheus/prometheus.yml
```

### start the contrainers
Deploy the monitoring stack (Grafana + Prometheus + Node Exporter)
```
cd $HOME/cosmos_node_monitoring
docker compose --profile monitor --env-file ./config/.env up -d
```

Deploy the monitor stack and the alerting stack (alert manager + alerta + telegram bot)
```
cd $HOME/cosmos_node_monitoring
docker compose --profile alert --env-file ./config/.env up -d
```
