import requests
import re
import time
import os

# Replace this with your Discord webhook URL
URL = ''

# Color constants
RED = 16711680

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
        with open('ZOMDIR/Zomboid/server-console.txt', 'r') as file:
            for line in file:
                line = line.strip()

                DISCONN = re.search(r'Finally disconnected client (\d+)', line)
                CONN_LOST = re.search(r'Connection Lost for id=(\d+) username=([a-zA-Z_0-9_]+)', line)
                CONN_CLOSED = re.search(r'Disconnected player "([a-zA-Z0-9]+)"', line)

                if DISCONN:
                    disconn_client_id = DISCONN.group(1)
                    with open('/tmp/disconn.out', 'w') as out_file:
                        out_file.write(disconn_client_id)

                if CONN_LOST:
                    conn_lost_client_id = CONN_LOST.group(1)
                    with open('/tmp/conn_lost.out', 'w') as out_file:
                        out_file.write(conn_lost_client_id)

                if CONN_CLOSED:
                    conn_closed_username = CONN_CLOSED.group(1)
                    with open('/tmp/conn_closed.out', 'w') as out_file:
                        out_file.write(conn_closed_username)

                if DISCONN:
                    if os.path.exists('/tmp/conn_lost.out'):
                        with open('/tmp/conn_lost.out', 'r') as in_file:
                            conn_lost_username = in_file.read().strip()
                            if conn_lost_username:
                                send_discord_message(RED, "User has lost connection to the server", f"User: {conn_lost_username}")
                                os.remove('/tmp/conn_lost.out')

                    if os.path.exists('/tmp/conn_closed.out'):
                        with open('/tmp/conn_closed.out', 'r') as in_file:
                            conn_closed_username = in_file.read().strip()
                            if conn_closed_username:
                                send_discord_message(RED, "User has disconnected", f"User: {conn_closed_username}")
                                os.remove('/tmp/conn_closed.out')

                    os.remove('/tmp/disconn.out')

if __name__ == '__main__':
    reader()
