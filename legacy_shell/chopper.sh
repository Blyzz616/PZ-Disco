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
    ###### Chopper Event Stuff
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
   # Clear chopper variables
    unset CHOP_ACTIVE
    unset CHOP_ARRIVE
    unset CHOP_SEARCH
    unset CHOP_LEAVE

    ###### End of Chopper Event stuff

  done

}

READER
