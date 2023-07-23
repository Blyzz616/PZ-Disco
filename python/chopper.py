import requests
import time
import random

# Replace this with your Discord webhook URL
URL = ''
# Insert the Zomboid directory here
ZOMDIR = ''

# Color constants
DISCORDBLUE = 45015
ORANGE = 16753920
RED = 16711680
CHARTREUSE = 8388352

# Chopper event messages
CHOP_ACTIVE_MESSAGES = [
    'What was that?',
    'Did you hear something',
    'What was that sound?',
    'Do you hear something?',
    'Uhm, I think we might have a problem...',
    'Shh shh shh shh, listen...',
    'Wait, QUIEIT! I think I hear something',
]

CHOP_ARRIVE_MESSAGES = [
    'Is that a helicopter?',
    'Kinda sounds like a motorbike.',
    'Whoa! Is that Search and Rescue?',
    'Is is a bird? A plane? Nope... just a chopper',
]

CHOP_SEARCH_MESSAGES = [
    'Why is it flying back and forth like that?',
    'I think it might be looking for us!.',
    'I think that he is flying a search pattern',
    'If he keeps flying around like that he will bring down a horde on us!',
]

CHOP_LEAVE_MESSAGES = [
    'Wait... Why is he leaving?',
    'Phew, He is leaving, I think we may be safe now.',
    'Yeah, thats right, fly away and do not come back!',
    'I think we are truly alone now',
]


def send_discord_message(color, title, description):
    data = {
        'embeds': [{
            'color': color,
            'title': title,
            'description': description,
        }]
    }
    headers = {'Content-Type': 'application/json'}
    requests.post(URL, json=data, headers=headers)


def reader():
    while True:
        with open('ZOMDIR/server-console.txt', 'r') as file:
            for line in file:
                line = line.strip()

                if 'chopper: activated' in line:
                    message = random.choice(CHOP_ACTIVE_MESSAGES)
                    send_discord_message(DISCORDBLUE, 'Chopper Event', message)

                elif 'state Arriving -> Hovering' in line:
                    message = random.choice(CHOP_ARRIVE_MESSAGES)
                    send_discord_message(ORANGE, 'Chopper Event', message)

                elif 'state Hovering -> Searching' in line:
                    message = random.choice(CHOP_SEARCH_MESSAGES)
                    send_discord_message(RED, 'Chopper Event', message)

                elif 'Searching -> Leaving' in line:
                    message = random.choice(CHOP_LEAVE_MESSAGES)
                    send_discord_message(CHARTREUSE, 'Chopper Event', message)

        time.sleep(1)


if __name__ == '__main__':
    reader()
