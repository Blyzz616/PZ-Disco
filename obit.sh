#! /bin/bash

RED=16711680

# Line 7 needs to contain your Webhook URL in full. Next line is an example
#URL='https://discord.com/api/webhooks/931526008698012384/9PF5y2X8d55z064xaCavlXgMuF9cb9N42PrrNESrnIGc1L0znHyIZLfQRPFGPUtmyNAr'
URL=''
source /usr/local/bin/colours.lib

    # Lets put in some funny death messages
    RANDOS=('just died.' 'has now made ther contribution to the horde.' 'swapped sides.' 'has now completed their playthough.' 'used the wrong hole.' 'kicked the bucket.' 'decided to try something else (it did not work).' 'forgot to pay their tribute to the R-N-Geezus.' 'bought the farm.''is still walking... breathing... not so much' )

SURVEY(){
VOYEUR=$(ls /root/Zomboid/Logs/ | grep 'user' | tail -n1)
  tail -fn0 /root/Zomboid/Logs/$VOYEUR | \
  while read LINE ; do

    # We're gonna need a seed
    RANDOM=$$$(date +%s)

    DEADPLAYER=$(echo "$LINE" | egrep -o '\S+\sdied' | awk '{print $1}')
    if [[ ! -z $DEADPLAYER ]];
    then
      MESSAGE1=${RANDOS[ $RANDOM % ${#RANDOS[@]} ]}
      OBIT="_$(date +%H:%M):_ **$DEADPLAYER** $MESSAGE1"
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"description\": \"$OBIT\" }] }" $URL
      DEADPLAYER=""
    fi

    # test if the VOYEUR file is still the current log file
    if [[ $VOYEUR != $(ls /root/Zomboid/Logs/ | grep 'user' | tail -n1) ]];
    then
      SURVEY
    fi
  done
SURVEY

}

TEST(){
  [[ $(find /root/Zomboid/Logs/ -maxdepth 1 -name '*user.txt' | wc -l) -eq 0 ]] && PRESENT=0 || PRESENT=1

  if [[ $PRESENT -eq 0 ]]
  then
    sleep 1
    TEST
  else
    SURVEY
  fi

}

TEST
