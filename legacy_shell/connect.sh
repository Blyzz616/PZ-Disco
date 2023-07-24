#! /bin/bash

# ADD YOUR DISCORD WEBHOOK TO THE NEXT LINE
URL=''

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

  tail -Fn0 /root/Zomboid/server-console.txt 2> /dev/null | \
  while read -r line ; do

    ###########################################################################
    ###### Connections
    ###########################################################################

    CONN_IN=$(echo "$line" | grep -E -o 'Client connecting')
    CONN_INIT=$(echo "$line" | grep -E -o 'Steam client [0-9]+ is initiating' | awk '{print $3}')
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
      touch /root/users.log /root/access.log /root/denied.log
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
#      COUNTER
    fi

    # Clear connection variables
    unset CONN_IN
    unset CONN_INIT
    unset CONN_AUTH_DENIED
#    unset CONN_AUTH_GRANTED
    unset CONN_PING_USER
    unset CONN_PING_TIME

    ###### End of Connections

  done

}

READER
