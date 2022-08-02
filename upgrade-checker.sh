#!/bin/sh
NODE=$(cat )
echo "$(date +%D-%H:%M:%S)" "Checking for any upgrades"  >> /var/log/upgrade-checker.log
~/go/bin/seid q upgrade plan --output json | jq -r .height
if $?; then
  HEIGHT=$(~/go/bin/seid q upgrade plan --output json --node tcp://$NODE:26657| jq -r .height)
  echo "$(date +%D-%H:%M:%S)" "Upgrade found at $HEIGHT. Setting alert and restart alertmanager"
  UPGRADE_HEIGHT=$HEIGHT envsubst < alert.rules.TEMPLATE > /home/ubuntu/sei-node-monitoring/prometheus/alerts/alert.rules
  docker compose down && docker compose up -d
else
  echo "$(date +%D-%H:%M:%S)" "No upgrade found" >> /var/log/upgrade-checker.log
fi
