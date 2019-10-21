#!/bin/bash

cd minecraft
nohup java -Xmx1G -Xms1G -jar server.jar nogui >/dev/null 2>&1 &
