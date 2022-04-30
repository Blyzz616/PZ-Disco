#! /bin/bash

URL='https://discord.com/api/webhooks/931522600658698280/9PF5Y2X8d55z06gxaCavlXgMuF9cb9Ne2PYrNESrnIGc1L0znHyIZLfQRPF7PUtmyNAr'

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
#      COUNTER
      unset DISCONN
      rm /tmp/disconn.out
    fi

    # Clear disconnection variables
    unset PLAYERID
    unset PLAYER

    ###### End of Disconnections

  done

}

READER
