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
    ######  Server going down
    ###########################################################################

    ENDOFLINE=$(echo "$line" | grep -E -o 'command\sentered\svia\sserver\sconsole\s\(System\.in\):\s\"quit\"')
    if [[ -n $ENDOFLINE ]];
    then
      TITLE="Server shutdown initiated. Server going down **NOW**"
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

      ###### NEED TO SHUT DOWN ALL THE MONITORING SCRIPTS
      kill -9 $(ps aux | grep chopper.sh | grep -v grep | awk '{print $2}')
      kill -9 $(ps aux | grep obit.sh | grep -v grep | awk '{print $2}')
      kill -9 $(ps aux | grep connect.sh | grep -v grep | awk '{print $2}')
      kill -9 $(ps aux | grep discon.sh | grep -v grep | awk '{print $2}')

    fi

    ###### End of Disconnections

  done

}

READER
