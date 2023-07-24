#!/bin/bash

# CHANGE THE NEXT LINE TO INCLUDE YOUR DISCORD WEBHOOK URL
URL=''
BLUE=45015

# CHANGE THE NEXT LINE TO INCLUDE YOUR OW CUSTOM SERVER INIT MESSAGE
MESSAGE="**Knox county** server coming up now."

# CHANGE THE NEXT LINE TO INCLUDE YOUR SERVER SETTINGS (typically the .ini file located in the /root/Zomboid/Server/ dir)
SRVRINI="servertest"

date +%s > /tmp/srvr-start.time
curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$BLUE\", \"description\": \"$MESSAGE\" }] }" $URL

# Start new screen session
screen -dm -s /bin/bash -S boid

# Start all the watcher scripts
/usr/local/bin/boid/startup.sh &
/usr/local/bin/boid/obit.sh &
/usr/local/bin/boid/connect.sh &
/usr/local/bin/boid/discon.sh &
/usr/local/bin/boid/chopper.sh &
/usr/local/bin/boid/shutdown.sh &

# start Zomboid server
screen -S boid -p 0 -X stuff "/bin/bash /home/boid/install/start-server.sh -servername $SRVRINI ^M"
