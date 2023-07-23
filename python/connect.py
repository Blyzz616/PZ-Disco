import requests
import re
import time

# Replace this with your Discord webhook URL
URL = ''

# Color constants
DISCORDBLUE = 45015
PURPLE = 8388736
RED = 16711680
CHARTREUSE = 8388352

# Insert the Zomboid directory here
ZOMDIR = ''

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

def read_steam_username(steam_id):
    STEAMLINK = f'https://steamcommunity.com/profiles/{steam_id}'
    response = requests.get(STEAMLINK)
    steam_name = re.search(r'"personaname":"([^,]+)', response.text)
    return steam_name.group(1) if steam_name else None

def reader():
    while True:
        with open('ZOMDIR/server-console.txt', 'r') as file:
            for line in file:
                line = line.strip()

                CONN_IN = 'Client connecting' in line
                CONN_INIT = re.search(r'Steam client (\d+) is initiating', line)
                CONN_AUTH_DENIED = 'Client sent invalid server password' in line
                CONN_PING_USER = re.search(r'User (\w+) ping (\d+) ms', line)

                if CONN_IN:
                    TITLE = "Incoming connection"
                    send_discord_message(DISCORDBLUE, TITLE, '')

                if CONN_INIT:
                    steam_id = CONN_INIT.group(1)
                    steam_username = read_steam_username(steam_id)
                    if steam_username:
                        message = f"[{steam_username}](https://steamcommunity.com/profiles/{steam_id}) attempted connection"
                        send_discord_message(PURPLE, "Steam user attempting connection:", message)
                        with open('ZOMDIR/access.log', 'a') as access_log:
                            access_log.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - Steam user {steam_username} (https://steamcommunity.com/profiles/{steam_id}) attempted connection\n")

                if CONN_AUTH_DENIED:
                    TITLE = "Access Denied - Check your credentials."
                    send_discord_message(RED, TITLE, '')
                    if steam_username:
                        with open('ZOMDIR/denied.log', 'a') as denied_log:
                            denied_log.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - Steam user {steam_username} (https://steamcommunity.com/profiles/{steam_id}) was denied connection\n")

                if CONN_PING_USER:
                    user_name = CONN_PING_USER.group(1)
                    ping_time = CONN_PING_USER.group(2)
                    TITLE = "Access Granted"
                    WELCOME = f"Welcome to BlyzzPlays {user_name}!"
                    BACK = f"Welcome back {user_name}!"

                    if steam_username:
                        with open('ZOMDIR/access.log', 'a') as access_log:
                            access_log.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - Steam user {steam_username} (https://steamcommunity.com/profiles/{steam_id}) completed connection with a ping of {ping_time} ms\n")

                        with open('ZOMDIR/users.log', 'a+') as users_log:
                            if steam_id not in users_log.read():
                                users_log.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - New User (Steam Name: {steam_username}) joined the server for the first time as \"{user_name}\"\n")
                                send_discord_message(CHARTREUSE, WELCOME, '')
                            else:
                                send_discord_message(CHARTREUSE, BACK, '')

                # Clear connection variables
                CONN_IN = False
                CONN_INIT = None
                CONN_AUTH_DENIED = False
                CONN_PING_USER = None

if __name__ == '__main__':
    reader()
