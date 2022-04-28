#! /bin/bash

# You ned to add your own web-hook to line 5 inbetween the single quotes. Example:
#
URL=''

# Some colours that Discord uses in binray
PINK=16761035
CRIMSON=14423100
RED=16711680
MAROON=8388608
BROWN=10824234
MISTYROSE=16770273
SALMON=16416882
CORAL=16744272
ORANGERED=16729344
CHOCOLATE=13789470
ORANGE=16753920
GOLD=16766720
IVORY=16777200
YELLOW=16776960
OLIVE=8421376
YELLOWGREEN=10145074
LAWNGREEN=8190976
CHARTREUSE=8388352
LIME=65280
GREEN=32768
SPRINGGREEN=65407
AQUAMARINE=8388564
TURQUOISE=4251856
AZURE=15794175
AQUACYAN=65535
TEAL=32896
LAVENDER=15132410
BLUE=255
DISCORDBLUE=45015
NAVY=128
BLUEVIOLET=9055202
INDIGO=4915330
DARKVIOLET=9699539
PLUM=14524637
MAGENTA=16711935
PURPLE=8388736
REDVIOLET=13047173
TAN=13808780
BEIGE=16119260
SLATEGRAY=7372944
SLATEGREY=7372944
DARKSLATEGRAY=3100495
DARKSLATEGREY=3100495
WHITE=16777215
WHITESMOKE=16119285
LIGHTGRAY=13882323
LIGHTGREY=13882323
SILVER=12632256
DARKGRAY=11119017
DARKGREY=11119017
GRAY=8421504
GREY=8421504
BLACK=0


READER(){

  tail -fn0 /root/Zomboid/server-console.txt 2> /dev/null | \
  while read -r line ; do

    ###########################################################################
    ################## Chopper Event Stuff ####################################
    ###########################################################################

    # We're gonna need a seed
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
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$DISCORDBLUE\", \"title\": \"$TITLE\", \"description\": \"$MESS_ACTIVE\" }] }" $URL
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
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$ORANGE\", \"title\": \"$TITLE\", \"description\": \"$MESS_ARRIVE\" }] }" $URL
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
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$TITLE\", \"description\": \"$MESS_SEARCH\" }] }" $URL
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
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$CHARTREUSE\", \"title\": \"$TITLE\", \"description\": \"$MESS_LEAVE\" }] }" $URL
    fi
   # Clear chopper variables - just in case
    unset CHOP_ACTIVE
    unset CHOP_ARRIVE
    unset CHOP_SEARCH
    unset CHOP_LEAVE

    ###### End of Chopper Event Stuff
    
    
    ###########################################################################
    ################## Connections ############################################
    ###########################################################################

    CONN_IN=$(echo "$line" | grep -E -o 'Client connecting')
    CONN_INIT=$(echo "$line" | grep -E -o 'Steam client [0-9]+ is initiating' | awk '{print $3}')
    # Next line left in in case I want to use it later - Ccech line 197
#    CONN_AUTH_GRANTED=$(echo "$line" | grep -E -o 'Auth succeeded')
    CONN_AUTH_DENIED=$(echo "$line" | grep -E -o 'Client sent invalid server password')
    CONN_PING_USER=$(echo "$line" | grep -E -o 'User \w+ ping [0-9]+ ms' | awk '{print $2}')
    CONN_PING_TIME=$(echo "$line" | grep -E -o 'User \w+ ping [0-9]+ ms' | awk '{print $4}')

    if [[ -n $CONN_IN ]];
    then
      TITLE="Incoming connection"
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$DISCORDBLUE\", \"title\": \"$TITLE\" }] }" $URL
    fi
    if [[ -n $CONN_INIT ]];
    then
      STEAMLINK="https://steamcommunity.com/profiles/$CONN_INIT"
      # get steam user page
      wget -O "/tmp/$CONN_INIT" "$STEAMLINK"
      #get Steam Username
      STEAMNAME=$(grep -E -o 'personaname\":\"[^,]+' "/tmp/$CONN_INIT" | sed -e 's/\"//g' | awk -F: '{print $2}')

      # lets keep a record of who joins the server
      touch /root/users.log
      touch /root/access.log
      touch /root/denied.log
      echo "$(date +%Y-%m-%d\ %H:%M:%S) - Steam user $STEAMNAME ($STEAMLINK) attempted connection" >> /root/access.log
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$PURPLE\", \"title\": \"Steam user attempting connection:\", \"description\": \"[$STEAMNAME]($STEAMLINK)\" }] }" $URL
    fi
    if [[ -n $CONN_AUTH_DENIED ]];
    then
      TITLE="Access Denied - Check your credentials."
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$TITLE\" }] }" $URL
      echo "$(date +%Y-%m-%d\ %H:%M:%S) - Steam user $STEAMNAME ($STEAMLINK) was denied connection" >> /root/denied.log
    fi
    if [[ -n $CONN_PING_USER ]];
    then
      TITLE="Access Granted"
      WELCOME="Welcome to BlyzzPlays $CONN_PING_USER!"
      BACK="Welcome back $CONN_PING_USER!"
      echo "$(date +%Y-%m-%d\ %H:%M:%S) - Steam user $STEAMNAME ($STEAMLINK) completed connection with a ping of $CONN_PING_TIME ms" >> /root/access.log
      if [[ $(grep -c "$CONN_INIT" /root/users.log) -eq 0 ]];
      then
        echo "$(date +%Y-%m-%d\ %H:%M:%S) - New User (Steam Name: $STEAMNAME) joined the server for the first time as \"$CONN_PING_USER\"" >> /root/users.log
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$CHARTREUSE\", \"title\": \"$WELCOME\" }] }" $URL
      else
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$CHARTREUSE\", \"title\": \"$BACK\" }] }" $URL
      fi
      COUNTER
    fi

    # Clear connection variables
    unset CONN_IN
    unset CONN_INIT
    unset CONN_AUTH_DENIED
    # Check line 145
#    unset CONN_AUTH_GRANTED
    unset CONN_PING_USER
    unset CONN_PING_TIME

    ###### End of Connections


    ###########################################################################
    ######  Disconnections
    ###########################################################################

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
#    PLAYERID=$(echo "$line" | grep -E -o 'Disconnecting client #[0-9]+ SteamID=[0-9]+' | awk -F= '{print $2}')
#    PLAYER=$(grep "$PLAYERID" /root/users.log | awk '{print $NF}')

    if [[ -n $DISCONN ]];
    then
      CONN_LOST=$(cat /tmp/conn_lost.out)
      CONN_CLOSED=$(cat /tmp/conn_closed.out)
      if [[ -n $CONN_CLOSED ]];
      then
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"User has disconnected\", \"description\": \"User: $CONN_CLOSED\" }] }" $URL
        unset CONN_CLOSED
        rm /tmp/conn_closed.out
      fi
      if [[ -n $CONN_LOST ]];
      then
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"User has lost connection to the server\", \"description\": \"User: $CONN_LOST\" }] }" $URL
        unset CONN_LOST
        rm /tmp/conn_lost.out
      fi
      COUNTER
      unset DISCONN
      rm /tmp/disconn.out
    fi

    # Clear disconnection variables
    unset PLAYERID
    unset PLAYER

    ###########################################################################
    ###### End of Disconnections
    ###########################################################################


    ###########################################################################
    ######  Server going down
    ###########################################################################

    ENDOFLINE=$(echo "$line" | grep -E -o 'command\sentered\svia\sserver\sconsole\s\(System\.in\):\s\"quit\"')
    if [[ -n $ENDOFLINE ]];
    then
      TITLE="Server is going down **NOW**"
      #get timestamp from srvr-up.time
      TIMEUP=$(cat /tmp/srvr-up.time)
      #calculate up-time
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
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$ORANGE\", \"title\": \"$TITLE\", \"description\": \"$MESSAGE\" }] }" $URL

    fi
    
    ###### End of Disconnections

  done
}


COUNTER(){
  # Get the count
  NOWCOUNT=$(screen -S boid -p 0 -X stuff "players^M" && sleep 0.1 && tail -n15 /root/Zomboid/server-console.txt | grep -E -v '^-'  | grep -E -o "connected \([0-9]+\)" | awk '{print $2}' | sed -e 's/(//' | sed -e 's/)//' | tail -n1)

  tail -n50 /root/Zomboid/server-console.txt | tac > /tmp/rawplayers.list
  sed '/Players connected/q' /tmp/rawplayers.list | grep -E -v '^$|^LOG' > /tmp/players.list

  #Put it where it belongs
  if [[ -n $NOWCOUNT ]];
  then

      MESSAGE="__Currently Connected:__ \`$NOWCOUNT\`"
      PLAYERLIST=$(cat /tmp/players.list)
      PLAYER1=$(echo "$PLAYERLIST" | awk '{print $1}')
      PLAYER2=$(echo "$PLAYERLIST" | awk '{print $2}')
      PLAYER3=$(echo "$PLAYERLIST" | awk '{print $3}')
      PLAYER4=$(echo "$PLAYERLIST" | awk '{print $4}')
      PLAYER5=$(echo "$PLAYERLIST" | awk '{print $5}')
      PLAYER6=$(echo "$PLAYERLIST" | awk '{print $6}')
      PLAYER7=$(echo "$PLAYERLIST" | awk '{print $7}')
      PLAYER8=$(echo "$PLAYERLIST" | awk '{print $8}')
      PLAYER9=$(echo "$PLAYERLIST" | awk '{print $9}')
      PLAYER10=$(echo "$PLAYERLIST" | awk '{print $10}')
      PLAYER11=$(echo "$PLAYERLIST" | awk '{print $11}')
      PLAYER12=$(echo "$PLAYERLIST" | awk '{print $12}')
      PLAYER13=$(echo "$PLAYERLIST" | awk '{print $13}')
      PLAYER14=$(echo "$PLAYERLIST" | awk '{print $14}')
      PLAYER15=$(echo "$PLAYERLIST" | awk '{print $15}')
      PLAYER16=$(echo "$PLAYERLIST" | awk '{print $16}')


    case $NOWCOUNT in

      0)
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$GREY\", \"title\": \"No-one is currently connected\" }]}" $URL
        ;;

      1)
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$GREY\", \"title\": \"$MESSAGE\" }]}" $URL
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER1\" }]}\
        " $URL
        ;;

      2)
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$GREY\", \"title\": \"$MESSAGE\" }]}" $URL
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER1\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER2\" }]}\
        " $URL
        ;;

      3)
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$GREY\", \"title\": \"$MESSAGE\" }]}" $URL
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER1\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER2\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER3\" }]}\
        " $URL
        ;;

      4)
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$GREY\", \"title\": \"$MESSAGE\" }]}" $URL
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER1\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER2\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER3\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER4\" }]}\
        " $URL
        ;;

      5)
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$GREY\", \"title\": \"$MESSAGE\" }]}" $URL
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER1\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER2\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER3\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER4\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER5\" }]}\
        " $URL
        ;;

      6)
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$GREY\", \"title\": \"$MESSAGE\" }]}" $URL
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER1\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER2\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER3\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER4\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER5\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER6\" }]}\
        " $URL
        ;;

       7)
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$GREY\", \"title\": \"$MESSAGE\" }]}" $URL
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER1\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER2\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER3\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER4\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER5\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER6\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER7\" }]}\
        " $URL
        ;;

      8)
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$GREY\", \"title\": \"$MESSAGE\" }]}" $URL
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER1\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER2\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER3\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER4\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER5\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER6\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER7\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER8\" }]}\
        " $URL
        ;;

      9)
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$GREY\", \"title\": \"$MESSAGE\" }]}" $URL
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER1\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER2\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER3\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER4\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER5\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER6\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER7\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER8\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER9\" }]}\
        " $URL
        ;;

      10)
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$GREY\", \"title\": \"$MESSAGE\" }]}" $URL
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER1\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER2\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER3\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER4\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER5\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER6\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER7\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER8\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER9\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER10\" }]}\
        " $URL
        ;;

      11)
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$GREY\", \"title\": \"$MESSAGE\" }]}" $URL
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER1\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER2\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER3\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER4\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER5\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER6\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER7\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER8\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER9\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER10\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER11\" }]}\
        " $URL
        ;;

      12)
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$GREY\", \"title\": \"$MESSAGE\" }]}" $URL
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER1\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER2\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER3\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER4\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER5\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER6\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER7\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER8\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER9\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER10\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER11\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER12\" }]}\
        " $URL
        ;;

      13)
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$GREY\", \"title\": \"$MESSAGE\" }]}" $URL
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER1\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER2\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER3\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER4\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER5\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER6\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER7\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER8\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER9\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER10\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER11\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER12\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER13\" }]}\
        " $URL
        ;;

      14)
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$GREY\", \"title\": \"$MESSAGE\" }]}" $URL
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER1\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER2\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER3\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER4\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER5\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER6\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER7\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER8\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER9\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER10\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER11\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER12\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER13\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER14\" }]}\
        " $URL
        ;;

      15)
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$GREY\", \"title\": \"$MESSAGE\" }]}" $URL
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER1\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER2\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER3\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER4\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER5\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER6\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER7\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER8\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER9\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER10\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER11\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER12\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER13\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER14\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER15\" }]}\
        " $URL
        ;;

      *)
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$GREY\", \"title\": \"$MESSAGE\" }]}" $URL
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER1\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER2\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER3\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER4\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER5\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER6\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER7\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER8\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER9\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER10\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER11\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER12\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER13\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER14\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER15\" },\
        { \"color\": \"$GREY\", \"description\": \"$PLAYER16\" }]}\
        " $URL
        ;;

    esac

  fi

}

READER
