#!/bin/bash

#
# https://minecraft-server.eu/forum/threads/linux-start-restart-script.51118/
#

# Insert path to minecraft_server.jar here
DIR="minecraft"
s_jar="server.jar"
r_time=30

##############################################################################

case "$1" in

start)
# check if there is a screen called "minecraft"
is_it_running=`screen -ls | grep minecraft`
if [ "$is_it_running" != "" ]
then
  echo "*** There is already a screen called 'minecraft' running. Aborting!"
else
  echo "*** Starting minecraft-server on screen 'minecraft'"
  cd $DIR
  # screen -A -m -d -L -S minecraft java -Xincgc -Xmx512M -XX:+UseConcMarkSweepGC -jar paperclip.jar -o true -h 127.0.0.1 -p 25565 -s 100 --log-append false --log-limit 50000
  #screen -A -m -d -L -S sh run_nogui.sh
  sh run_nogui.sh
  # check if it is running now
  status=`screen -ls | grep minecraft`
  if [ "$status" == "" ]
  then
    echo "*** Starting failed!"
  else
    echo "*** Server started successfully!"
    echo "*** You may now connect to console via 'screen -r minecraft'"
    echo $status
  fi
fi
;;


stop)
echo "*** Looking for running minecraft-Server via 'screen'"

#check if there is a screen called "minecraft"
is_it_running=`screen -ls | grep minecraft`
if [ "$is_it_running" != "" ]
then
  echo "*** Running minecraft-server found:" $is_it_running
  echo "*** Saving chunks with 'save-all'"
  screen -dr minecraft -p 0 -X stuff "$(printf "save-all\r")"
  echo "*** Sending message to players, that server will shutdown in 30 sec"
  screen -dr minecraft -p 0 -X stuff "$(printf "broadcast Server will be shutdown in 30sec...\r")"
  echo "*** Message sent. Wait 30 sec ..."
  sleep 30
  screen -dr minecraft -p 0 -X stuff "$(printf "say Server stopping ...\r")"
  echo ""
  echo "*** Stopping" $is_it_running "now."
  screen -dr minecraft -p 0 -X stuff "$(printf "stop\r")"

  #wait a while and then test if screen is there
  sleep 10
  status_off=`screen -ls | grep minecraft`

  if [ "$status_off" == "" ]
  then
    echo "*** minecraft-Server stopped!" $status_off
  else
    echo "*** Something went wrong!" $status_off
  fi
else
  echo "*** No screen called 'minecraft' found. Is server really running?"
fi
;;

status)
#check if there is a screen called "minecraft"
is_it_running=`screen -ls | grep minecraft`

if [ "$is_it_running" != "" ]
then
echo "*** Running minecraft-server found:" $is_it_running
else
echo "*** No screen called 'minecraft' found. Is server really running?"
fi
;;


webstat)
#check if there is a screen called "minecraft"
is_it_running=`screen -ls | grep minecraft`

if [ "$is_it_running" != "" ]
then
echo "1"
else
echo "0"
fi
;;


restart)
#check if there is a screen called "minecraft"
is_it_running=`screen -ls | grep minecraft`
if [ "$is_it_running" != "" ]
then
  echo "*** Sending message to players, that server will restart in $r_time sec"
  screen -dr minecraft -p 0 -X stuff "$(printf "broadcast Server restart in $r_time secs!!\r")"
  echo "*** Message sent. Wait $r_time sec ..."
  sleep $r_time
  echo "*** Saving chunks with 'save-all'"
  screen -dr minecraft -p 0 -X stuff "$(printf "save-all\r")"
  screen -dr minecraft -p 0 -X stuff "$(printf "say Server will be restarted.\r")"
  sleep 5
  echo "*** Stopping" $is_it_running "now."
  screen -dr minecraft -p 0 -X stuff "$(printf "stop We will be back\r")"

  echo "*** Check for stopped Server"
  s_running=`screen -ls | grep minecraft`
  if [$s_running != "" ]
  then
    $s_running="TRUE"
  else
    $s_running="FALSE"
  fi
  while [ $s_running != "TRUE" ]
    do
      sleep 2
      s_running=`screen -ls | grep minecraft`
      if [$s_running != "" ]
      then
        $s_running="TRUE"
      else
        $s_running="FALSE"
      fi
    done

  echo "*** Starting minecraft-Server on screen 'minecraft'"
  cd $DIR
  screen -A -m -d -L -S minecraft java -Xincgc -Xmx512M -XX:+UseConcMarkSweepGC -jar paperclip.jar -o true -h 127.0.0.1 -p 25565 -s 100 --log-append false --log-limit 50000

  #check if it is running now
  status=`screen -ls | grep minecraft`
  if [ "$status" == "" ]
  then
    echo "*** Starting failed!"
  else
    echo "*** Server started successfully!"
    echo "*** You may now connect to console via 'screen -r minecraft'"
    echo $status
  fi
else
  echo "*** No screen called 'minecraft' found. Is server really running?"
fi
;;

*)
echo $"*** Usage: $0 {start|stop|status|restart}"
exit 1
esac