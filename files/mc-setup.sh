#!/bin/bash

# sudo yum update -y
sudo yum install java-1.8.0 -y
sudo yum remove java-1.7.0-openjdk -y

mkdir minecraft
aws s3 sync s3://$1 minecraft/ --delete

# install minecraft if this is the first time
if [ ! -f "minecraft/eula.txt" ]; then
    echo "Installing Minecraft"
    cd minecraft
    # pick latest from https://www.minecraft.net/en-us/download/server/
    wget https://launcher.mojang.com/v1/objects/3dc3d84a581f14691199cf6831b71ed1296a9fdf/server.jar
    cat >eula.txt<<EOF
#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula).
#Tue Jan 27 21:40:00 UTC 2015
eula=true
EOF
    cd ..
fi

# install minecraft status 
sudo pip install mcstatus

# insert backup and auto-shutoff into cron tab
crontab -l | { cat; echo "*/5 * * * * aws s3 sync minecraft/ s3://$1"; } | crontab -
crontab -l | { cat; echo "*/5 * * * * python auto_shutoff.py"; } | crontab -
