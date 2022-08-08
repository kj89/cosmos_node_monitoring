#!/bin/bash
if [ -z "$1" ]
  then
    echo "Node IP must be provided"
fi
echo "=================================================="
echo -e "\033[0;35m"
echo " :::    ::: ::::::::::: ::::    :::  ::::::::  :::::::::  :::::::::: ::::::::  ";
echo " :+:   :+:      :+:     :+:+:   :+: :+:    :+: :+:    :+: :+:       :+:    :+: ";
echo " +:+  +:+       +:+     :+:+:+  +:+ +:+    +:+ +:+    +:+ +:+       +:+        ";
echo " +#++:++        +#+     +#+ +:+ +#+ +#+    +:+ +#+    +:+ +#++:++#  +#++:++#++ ";
echo " +#+  +#+       +#+     +#+  +#+#+# +#+    +#+ +#+    +#+ +#+              +#+ ";
echo " #+#   #+#  #+# #+#     #+#   #+#+# #+#    #+# #+#    #+# #+#       #+#    #+# ";
echo " ###    ###  #####      ###    ####  ########  #########  ########## ########  ";
echo -e "\e[0m"
echo "=================================================="

sleep 2

echo -e "\e[1m\e[32m1. Updating dependencies... \e[0m" && sleep 1
sudo apt-get update

echo "=================================================="

echo -e "\e[1m\e[32m2. Installing required dependencies... \e[0m" && sleep 1
sudo apt install jq -y
sudo apt install python3-pip -y
sudo pip install yq

echo "=================================================="

echo -e "\e[1m\e[32m3. Checking if Docker is installed... \e[0m" && sleep 1

if ! command -v docker &> /dev/null
then
    echo -e "\e[1m\e[32m3.1 Installing Docker... \e[0m" && sleep 1
    sudo apt-get install ca-certificates curl gnupg lsb-release wget -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io -y
fi

echo "=================================================="

echo -e "\e[1m\e[32m4. Checking if Docker Compose is installed ... \e[0m" && sleep 1

docker compose version
if [ $? -ne 0 ]
then
    echo -e "\e[1m\e[32m4.1 Installing Docker Compose v2.3.3 ... \e[0m" && sleep 1
    mkdir -p ~/.docker/cli-plugins/
    curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
    chmod +x ~/.docker/cli-plugins/docker-compose
    sudo chown $USER /var/run/docker.sock
fi

echo "=================================================="

echo -e "\e[1m\e[32m5. Downloading Node Monitoring config files ... \e[0m" && sleep 1

rm -rf cosmos_node_monitoring
git clone https://github.com/sei-protocol/sei-node-monitoring.git

chmod +x /home/ubuntu/sei-node-monitoring/add_validator.sh
# Insert starting upgrade height
UPGRADE_HEIGHT=0 envsubst '${UPGRADE_HEIGHT}' < /home/ubuntu/sei-node-monitoring/prometheus/alerts/alert.rules.TEMPLATE > /home/ubuntu/sei-node-monitoring/prometheus/alerts/alert.rules
# Insert PagerDuty service key 
envsubst < /home/ubuntu/sei-node-monitoring/prometheus/alert_manager/alertmanager.yml.TEMPLATE > /home/ubuntu/sei-node-monitoring/prometheus/prometheus/alert_manager/alertmanager.yml



echo -e "\e[1m\e[32m5. Installing upgrade checker ... \e[0m"
curl -LO https://go.dev/dl/go1.18beta1.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.18beta1.linux-amd64.tar.gz
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
source ~/.bashrc
cd /home/ubuntu/ && git clone https://github.com/sei-protocol/sei-chain.git && cd sei-chain && make install
touch /var/log/upgrade-checker.log
chmod +x /home/ubuntu/sei-node-monitoring/upgrade-checker.sh
(crontab -l 2>/dev/null; echo "* * * * * /home/ubuntu/sei-node-monitoring/upgrade-checker.sh $1 >> /var/log/upgrade-checker.log 2>&1") | crontab -