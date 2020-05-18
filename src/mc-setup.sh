#!/bin/bash
set -eux

# sudo yum update -y
sudo yum install java-1.8.0 -y
sudo yum remove java-1.7.0-openjdk -y

# copy tf templates to minecraft backup bucket
aws s3 cp config.tf s3://$1
aws s3 cp variables.tf s3://$1
aws s3 cp account.tfvars s3://$1

# create minecraft dir and sync with world backup bucket 
mkdir minecraft
aws s3 sync s3://$1 minecraft/

# install minecraft if this is the first time
if [ ! -f "minecraft/eula.txt" ]; then
    echo "Installing Minecraft"
    cd minecraft
        rm forge.jar || true
        # pick latest from https://www.minecraft.net/en-us/download/server/
        #wget https://launcher.mojang.com/v1/objects/bb2b6b1aefcd70dfd1892149ac3a215f6c636b07/server.jar
        wget http://alx365.github.io/BTE_Official_Server_MAC.zip
        unzip BTE_Official_Server_MAC.zip
        rm BTE_Official_Server_MAC.zip
        sh install.sh

        cat >eula.txt<<EOF
#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula).
#Tue Jan 27 21:40:00 UTC 2015
eula=true
EOF

    cd ..
fi

# install minecraft status 
sudo pip install mcstatus

# insert auto-shutoff into cron tab and run each minute
crontab -l | { cat; echo "* * * * * python auto-shutoff.py s3://$1 $2 $3"; } | crontab -

# start minecraft (does not return)
cd minecraft
    rm nohup.out || true
    # copying from S3 drops the x perm
    chmod a+x run_nogui.sh
    nohup ./run_nogui.sh &
    sleep 10
    cat nohup.out
cd ..
