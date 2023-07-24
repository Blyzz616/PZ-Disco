#!/bin/bash

SCREEN01(){
ZOMDIR=($(find / -type d -name "Zomboid" 2>/dev/null))

if [[ "${#ZOMDIR[@]}" -lt 1 ]]; then
  whiptail --title "Project Zomboid not found" --msgbox "Project Zomboid needs to be installed before we can install DisBoid" 8 78
elif [[ "${#ZOMDIR[@]}" -gt 1 ]]; then

  whiptail_args=(
    --title "Select Directory"
    --radiolist "Select which Directory is your active Zomboid Install:"
    10 80 "${#ZOMDIR[@]}"
  )

  i=0
  for list in "${ZOMDIR[@]}"; do
    whiptail_args+=( "$((++i))" "$list" )
    if [[ "$list" = "$SELECTEDDIR" ]]; then
      whiptail_args+=( "on" )
    else
      whiptail_args+=( "off" )
    fi
  done

  whiptail_out=$(whiptail "${whiptail_args[@]}" 3>&1 1>&2 2>&3); whiptail_retval=$?

  if [ $whiptail_retval -eq 0 ]; then
    SELECTEDDIR=${ZOMDIR[whiptail_out - 1]}
  fi

else
  SELECTEDDIR="${ZOMDIR[0]}"
fi
}

SCREEN02(){
INI=($(find "$SELECTEDDIR/Server/" -name *.ini | awk -F"/" '{print $NF}' | awk -F. '{print $1}' 2>/dev/null))

if [[ "${#INI[@]}" -lt 1 ]]; then
  whiptail --title "No Server Config files found" --msgbox "You need to have at least one server configured to use DisBoid" 8 78
elif [[ "${#INI[@]}" -gt 1 ]]; then

  whiptail_args=(
    --title "Select the config file you are using"
    --radiolist "Select which config file is active:"
    10 80 "${#INI[@]}"
  )

  i=0
  for list in "${INI[@]}"; do
    whiptail_args+=( "$((++i))" "$list" )
    if [[ "$list" = "$SELECTEDINI" ]]; then
      whiptail_args+=( "on" )
    else
      whiptail_args+=( "off" )
    fi
  done

  whiptail_out=$(whiptail "${whiptail_args[@]}" 3>&1 1>&2 2>&3); whiptail_retval=$?

  if [ $whiptail_retval -eq 0 ]; then
    SELECTEDINI=${INI[whiptail_out - 1]}
  fi

else

  SELECTEDINI="${INI[0]}"

fi

}

SCREEN03(){
  SERVERNAME=$(whiptail --inputbox "What do you call this server on your Discord?" 8 78 --title "Human-readable Server Name" 3>&1 1>&2 2>&3)
  echo $SERVERNAME > /tmp/server.name
}
SCREEN04(){
  URL=$(whiptail --inputbox "Copy your Webhook URL and paste it in here." 8 78 --title "Webhook URL" 3>&1 1>&2 2>&3)
  echo $URL > /tmp/hook.url
  exitstatus=$?
  if [[ $exitstatus = 0 ]]; then
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"45015\", \"title\": \"Discord Webhook verified, please select 'Yes' in your DisBoid setup.\" }] }" "$URL"
  fi
}

SCREEN05(){
  if (whiptail --title "Discord Webhook Verification" --yesno "Did you get a message in your discord channel?." 8 78); then
    SCREEN06
else
    SCREEN04
fi
}

SCREEN06(){
    psw=$(whiptail --title "Sudo Password" --passwordbox "Enter your sudo password to create necessary files and folders." 10 78 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        sudo -S <<< "$psw" mkdir /opt/disboid; sudo -S <<< "$psw" chown "$(whoami):$(whoami)" /opt/disboid
        CHOPPER
        CONNECT
        DISCON
        OBIT
        SHUTDOWN
        STARTUP
    fi
}

START(){
  cat << 'EOF' > /home/"$(whoami)"/start.sh
#!/bin/bash

DISCORDURL
BLUE=45015

MESSAGE="**SERVERNAME** server coming up now."

SRVRINI="servertest"

date +%s > /tmp/srvr-start.time
curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$BLUE\", \"description\": \"$MESSAGE\" }] }" "$URL"

screen -dm -s /bin/bash -S boid

/opt/disboid/startup.sh &
/opt/disboid/obit.sh &
/opt/disboid/connect.sh &
/opt/disboid/discon.sh &
/opt/disboid/chopper.sh &
/opt/disboid/shutdown.sh &

screen -S boid -p 0 -X stuff "/bin/bash /home/boid/install/start-server.sh -servername $SRVRINI ^M"
EOF
}
FIXSTART(){
  sed -i -- "s/SERVERNAME/$SERVERNAME/g" /home/"$(whoami)"/start.sh
}
CHOPPER(){
  cat << 'EOF' > /opt/disboid/chopper.sh
#!/bin/bash

DISCORDURL
RED=16711680
CHARTREUSE=8388352
DISCORDBLUE=45015

READER(){

  tail -Fn0 SELECTEDDIR/server-console.txt 2> /dev/null | \
  while read -r line ; do

    RANDOM=$$$(date +%s)

    CHOP_ACTIVE=$(echo "$line" | grep -E -i 'chopper: activated')
    CHOP_ARRIVE=$(echo "$line" | grep -E -i 'state Arriving -> Hovering')
    CHOP_SEARCH=$(echo "$line" | grep -E -i 'state Hovering -> Searching')
    CHOP_LEAVE=$(echo "$line" | grep -E -i 'Searching -> Leaving')

    if [[ -n $CHOP_ACTIVE ]];
    then
      RAND_ACTIVE=(\
        'What was that?' \
        'Did you hear something' \
        'What was that sound?' \
        'Do you hear something?' \
        'Uhm, I think we might have a problem...' \
        'Shh shh shh shh, listen...' \
        'Wait, QUIEIT! I think I hear something' \
      )
      MESS_ACTIVE=${RAND_ACTIVE[ $RANDOM % ${#RAND_ACTIVE[@]} ]}
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$DISCORDBLUE\", \"title\": \"$TITLE\", \"description\": \"$MESS_ACTIVE\" }] }" "$URL"
    fi

    if [[ -n $CHOP_ARRIVE ]];
    then
      RAND_ARRIVE=(\
        'Is that a helicopter?' \
        'Kinda sounds like a motorbike.' \
        'Whoa! Is that Search and Rescue?' \
        'Is is a bird? A plane? Nope...  just a chopper' \
      )
      MESS_ARRIVE=${RAND_ARRIVE[ $RANDOM % ${#RAND_ARRIVE[@]} ]}
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$ORANGE\", \"title\": \"$TITLE\", \"description\": \"$MESS_ARRIVE\" }] }" "$URL"
    fi

    if [[ -n $CHOP_SEARCH ]];
    then
    RAND_SEARCH=(\
      'Why is it flying back and forth like that?' \
      'I think it might be looking for us!.' \
      'I think that he is flying a search pattern' \
      'If he keeps flying around like that he will bring down a horde on  us!' \
    )
    MESS_SEARCH=${RAND_SEARCH[ $RANDOM % ${#RAND_SEARCH[@]} ]}
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$TITLE\", \"description\": \"$MESS_SEARCH\" }] }" "$URL"
    fi

    if [[ -n $CHOP_LEAVE ]];
    then
      RAND_LEAVE=(\
        'Wait... Why is he leaving?' \
        'Phew, He is leaving, I think we may be safe now.' \
        'Yeah, thats right, fly away and do not come back!' \
        'I think we are truly alone now' \
      )
      MESS_LEAVE=${RAND_LEAVE[ $RANDOM % ${#RAND_LEAVE[@]} ]}
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$CHARTREUSE\", \"title\": \"$TITLE\", \"description\": \"$MESS_LEAVE\" }] }" "$URL"
    fi
    unset CHOP_ACTIVE
    unset CHOP_ARRIVE
    unset CHOP_SEARCH
    unset CHOP_LEAVE

  done

}

READER
EOF
}
CONNECT(){
  cat << 'EOF' > /opt/disboid/conect.sh
#! /bin/bash

DISCORDURL

RED=16711680

CHARTREUSE=8388352
DISCORDBLUE=45015

READER(){

tail -Fn0 ZOMDIR/server-console.txt 2> /dev/null | \
while read -r line ; do

  CONN_IN=$(echo "$line" | grep -E -o 'Client connecting')
  CONN_INIT=$(echo "$line" | grep -E -o 'Steam client [0-9]+ is initiating' | awk '{print $3}')
  CONN_AUTH_DENIED=$(echo "$line" | grep -E -o 'Client sent invalid server password')
  CONN_PING_USER=$(echo "$line" | grep -E -o 'User \w+ ping [0-9]+ ms' | awk '{print $2}')
  CONN_PING_TIME=$(echo "$line" | grep -E -o 'User \w+ ping [0-9]+ ms' | awk '{print $4}')

  if [[ -n $CONN_IN ]];
  then
    TITLE="Incoming connection"
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$DISCORDBLUE\", \"title\": \"$TITLE\" }] }" "$URL"
  fi
  if [[ -n $CONN_INIT ]];
  then
    STEAMLINK="https://steamcommunity.com/profiles/$CONN_INIT"
    wget -O "/tmp/$CONN_INIT" "$STEAMLINK"
    STEAMNAME=$(grep -E -o 'personaname\":\"[^,]+' "/tmp/$CONN_INIT" | sed -e 's/\"//g' | awk -F: '{print $2}')

    touch ZOMDIR/users.log ZOMDIR/access.log ZOMDIR/denied.log
    echo "$(date +%Y-%m-%d\ %H:%M:%S) - Steam user $STEAMNAME ($STEAMLINK) attempted connection" >> ZOMDIR/access.log
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$PURPLE\", \"title\": \"Steam user attempting connection:\", \"description\": \"[$STEAMNAME]($STEAMLINK)\" }] }" "$URL"
  fi
  if [[ -n $CONN_AUTH_DENIED ]];
  then
    TITLE="Access Denied - Check your credentials."
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$TITLE\" }] }" "$URL"
    echo "$(date +%Y-%m-%d\ %H:%M:%S) - Steam user $STEAMNAME ($STEAMLINK) was denied connection" >> ZOMDIR/denied.log
  fi
  if [[ -n $CONN_PING_USER ]];
  then
    TITLE="Access Granted"
    WELCOME="Welcome to BlyzzPlays $CONN_PING_USER!"
    BACK="Welcome back $CONN_PING_USER!"
    echo "$(date +%Y-%m-%d\ %H:%M:%S) - Steam user $STEAMNAME ($STEAMLINK) completed connection with a ping of $CONN_PING_TIME ms" >> ZOMDIR/access.log
    if [[ $(grep -c "$CONN_INIT" ZOMDIR/users.log) -eq 0 ]];
    then
      echo "$(date +%Y-%m-%d\ %H:%M:%S) - New User (Steam Name: $STEAMNAME) joined the server for the first time as \"$CONN_PING_USER\"" >> ZOMDIR/users.log
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$CHARTREUSE\", \"title\": \"$WELCOME\" }] }" "$URL"
    else
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$CHARTREUSE\", \"title\": \"$BACK\" }] }" "$URL"
    fi
  fi

  unset CONN_IN
  unset CONN_INIT
  unset CONN_AUTH_DENIED
  unset CONN_PING_USER
  unset CONN_PING_TIME

done

}

READER
EOF
}
DISCON(){
  cat << 'EOF' > /opt/disboid/discon.sh
#! /bin/bash

DISCORDURL
RED=16711680

READER(){

  tail -Fn0 ZOMDIR/server-console.txt 2> /dev/null | \
  while read -r line ; do

    DISCONN=$(echo "$line" | grep -E -o 'Finally disconnected client [0-9]+')
    if [[ -n $DISCONN ]];
    then
      echo "$DISCONN" > /tmp/disconn.out
    fi
    CONN_LOST=$(echo "$line" | grep -E -o 'Connection Lost for id=[0-9]+ username=[a-zA-Z_0-9_]+' | awk -F= '{print $3}')
    if [[ -n $CONN_LOST ]];
    then
      echo "$CONN_LOST" > /tmp/conn_lost.out
    fi
    CONN_CLOSED=$(echo "$line" | grep -E -o 'Disconnected player ["a-zA-Z0-9]+' | awk '{print $3}' | sed -e 's/"//g')
    if [[ -n $CONN_CLOSED ]];
    then
      echo "$CONN_CLOSED" > /tmp/conn_closed.out
    fi
    if [[ -n $DISCONN ]];
    then
      CONN_LOST=$(cat /tmp/conn_lost.out)
      CONN_CLOSED=$(cat /tmp/conn_closed.out)
      if [[ -n $CONN_CLOSED ]];
      then
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"User has disconnected\", \"description\": \"User: $CONN_CLOSED\" }] }" "$URL"
        unset CONN_CLOSED
        rm /tmp/conn_closed.out
      fi
      if [[ -n $CONN_LOST ]];
      then
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"User has lost connection to the server\", \"description\": \"User: $CONN_LOST\" }] }" "$URL"
        unset CONN_LOST
        rm /tmp/conn_lost.out
      fi
      unset DISCONN
      rm /tmp/disconn.out
    fi

    unset PLAYERID
    unset PLAYER
  done

}

READER
EOF
}
OBIT(){
  cat << 'EOF' > /opt/disboid/obit.sh
#! /bin/bash

RED=16711680
DISCORDURL

RANDOS=('just died.' 'has now made ther contribution to the horde.' 'swapped sides.' 'has now completed their playthough.' 'used the wrong hole.' 'kicked the bucket.' 'decided to try something else (it did not work).' 'forgot to pay their tribute to the R-N-Geezus.' 'bought the farm.''is still walking... breathing... not so much' )

OBITUARY(){
USERFILE=$(ls ZOMDIR/Logs/*user*)
  tail -fn0 "ZOMDIR/Logs/$USERFILE" | \
  while read -r LINE ; do

    RANDOM=$$$(date +%s)

    DEADPLAYER=$(echo "$LINE" | grep -E -o '\S+\sdied' | awk '{print $1}')
    if [[ -n $DEADPLAYER ]];
    then
      MESSAGE1=${RANDOS[ $RANDOM % ${#RANDOS[@]} ]}
      OBIT="_$(date +%H:%M):_ **$DEADPLAYER** $MESSAGE1"
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"description\": \"$OBIT\" }] }" "$URL"
      DEADPLAYER=""
    fi

    if [[ $VOYEUR != $(ls ZOMDIR/Logs/*user*) ]];
    then
      OBITUARY
    fi
  done
OBITUARY

}

VALIDATE(){
  [[ $(find ZOMDIR/Logs/ -maxdepth 1 -name '*user.txt' | wc -l) -eq 0 ]] && PRESENT=0 || PRESENT=1

  if [[ $PRESENT -eq 0 ]]
  then
    sleep 1
    VALIDATE
  else
    OBITUARY
  fi

}

VALIDATE
EOF
}
SHUTDOWN(){
  cat << 'EOF' > /opt/disboid/shutdown.sh
#! /bin/bash

DISCORDURL

ORANGE=16753920

READER(){

  tail -Fn0 ZOMDIR/server-console.txt 2> /dev/null | \
  while read -r line ; do

    ENDOFLINE=$(echo "$line" | grep -E -o 'command\sentered\svia\sserver\sconsole\s\(System\.in\):\s\"quit\"')
    if [[ -n $ENDOFLINE ]];
    then
      TITLE="Server shutdown initiated. Server going down **NOW**"
      TIMEUP=$(cat /tmp/srvr-up.time)
      TIMEDOWN=$(date +%s)
      UPSECS=$(( TIMEDOWN - TIMEUP ))
      if [[ $UPSECS -ge 86400 ]];
      then
        UPTIME=$(printf '%dd %dh %dm %ds' $((UPSECS/86400)) $((UPSECS%86400/3600)) $((UPSECS%3600/60)) $((UPSECS%60)))
      elif [[ $UPSECS -ge 3600  ]];
      then
        UPTIME=$(printf '%dh %dm %ds' $((UPSECS/3600)) $((UPSECS%3600/60)) $((UPSECS%60)))
      elif [[ $UPSECS -ge 60 ]];
      then
        UPTIME=$(printf '%dm %ds' $((UPSECS/60)) $((UPSECS%60)))
      else
        UPTIME=$(printf '%ds' $((UPSECS)))
      fi

      MESSAGE="The Server was up for $UPTIME"
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$ORANGE\", \"title\": \"$TITLE\", \"description\": \"$MESSAGE\" }] }" "$URL"
      kill -9 "$(ps aux | grep chopper.sh | grep -v grep | awk '{print $2}')"
      kill -9 "$(ps aux | grep obit.sh | grep -v grep | awk '{print $2}')"
      kill -9 "$(ps aux | grep connect.sh | grep -v grep | awk '{print $2}')"
      kill -9 "$(ps aux | grep discon.sh | grep -v grep | awk '{print $2}')"

    fi
  done

}

READER
EOF
}
STARTUP(){
  cat << 'EOF' > /opt/disboid/startup.sh
#! /bin/bash

DISCORDURL
LIME=65280

READER(){

  tail -Fn0 ZOMDIR/server-console.txt 2> /dev/null | \
  while read -r line ; do

    STARTVAR="SERVER STARTED"
    SRVRUP=$(echo "$line" | grep -E -c "$STARTVAR")
    if [[ "$SRVRUP" -gt "0" ]];
    then
      date +%s > /tmp/srvr-up.time
      RISING=$(cat /tmp/srvr-start.time)
      RISEN=$(cat /tmp/srvr-up.time)
      RISESECS=$(( RISEN - RISING ))
      SRVRNAME=$(ps aux | grep 'servername' | grep -v grep | grep Project | awk '{print $NF}')
      touch ZOMDIR/"$SRVRNAME".up
      echo "$(date +%c) $SRVRNAME RISESECS" >> ZOMDIR/"$SRVRNAME".up

      if [[ $RISESECS -ge 60 ]];
      then
        RISETIME=$(printf '%dm %ds' $((RISESECS/60)) $((RISESECS%60)))
      else
        RISETIME=$(printf '%ds' $((RISESECS)))
      fi
      TITLE="Server is now **ONLINE**"
      MESSAGE="Server took $RISETIME to come online."
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$LIME\", \"title\": \"$TITLE\", \"description\": \"$MESSAGE\" }] }" "$URL"
      unset UPNOW
      break
    fi

  done

}

READER
EOF
}
FIXURL(){
  sed -i "s@DISCORDURL@URL='$URL'@g" /opt/disboid/*
  sed -i "s@DISCORDURL@URL='$URL'@g" /home/"$(whoami)"/start.sh
}
FIXZOMDIR(){
  sed -i "s@ZOMDIR@$SELECTEDDIR@g" /opt/disboid/*
}
FIXINI(){
  sed -i "s@servertest@$SELECTEDINI@g" /home/"$(whoami)"/start.sh
}

SCREEN01
SCREEN02
SCREEN03
SCREEN04
SCREEN05
SCREEN06
unset psw
psw="null"
START
CHOPPER
CONNECT
DISCON
OBIT
SHUTDOWN
STARTUP
FIXSTART
FIXURL
FIXZOMDIR
FIXINI
