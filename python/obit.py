import requests
import re
import os
import time
import random

# Replace this with your Discord webhook URL
URL = ''

# Insert the Zomboid directory here
ZOMDIR = ''

# Color constant
RED = 16711680

# Funny death messages
RANDOS = [
    'just died.', 'has now made their contribution to the horde.', 'swapped sides.',
    'has now completed their playthrough.', 'used the wrong hole.', 'kicked the bucket.',
    'decided to try something else (it did not work).', 'forgot to pay their tribute to the R-N-Geezus.',
    'bought the farm.', 'is still walking... breathing... not so much'
]

def send_discord_message(color, description):
    data = {
        'embeds': [{
            'color': color,
            'description': description,
        }]
    }
    headers = {'Content-Type': 'application/json'}
    requests.post(URL, json=data, headers=headers)

def obituary():
    last_user_file = None
    while True:
        user_files = sorted([file for file in os.listdir('ZOMDIR/Logs/') if file.startswith('user')], reverse=True)
        current_user_file = user_files[0] if user_files else None

        if last_user_file != current_user_file:
            if current_user_file:
                with open(f'ZOMDIR/Logs/{current_user_file}', 'r') as file:
                    for line in file:
                        dead_player = re.search(r'(\S+)\sdied', line)
                        if dead_player:
                            player_name = dead_player.group(1)
                            message = f'_{time.strftime("%H:%M")}:_ **{player_name}** {random.choice(RANDOS)}'
                            send_discord_message(RED, message)

            last_user_file = current_user_file
        time.sleep(1)

def validate():
    while True:
        user_files = [file for file in os.listdir('ZOMDIR/Logs/') if file.startswith('user')]
        if not user_files:
            time.sleep(1)
        else:
            obituary()
            break

if __name__ == '__main__':
    validate()
