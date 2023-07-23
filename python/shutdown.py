import requests
import re
import time
import os
import subprocess

# Replace this with your Discord webhook URL
URL = ''

# Color constants
ORANGE = 16753920

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

def get_server_uptime():
    with open('/tmp/srvr-up.time', 'r') as file:
        start_time = int(file.read().strip())

    current_time = int(time.time())
    uptime_seconds = current_time - start_time

    if uptime_seconds >= 86400:
        uptime = f"{uptime_seconds // 86400}d {uptime_seconds % 86400 // 3600}h {uptime_seconds % 3600 // 60}m {uptime_seconds % 60}s"
    elif uptime_seconds >= 3600:
        uptime = f"{uptime_seconds // 3600}h {uptime_seconds % 3600 // 60}m {uptime_seconds % 60}s"
    elif uptime_seconds >= 60:
        uptime = f"{uptime_seconds // 60}m {uptime_seconds % 60}s"
    else:
        uptime = f"{uptime_seconds}s"

    return uptime

def stop_monitoring_scripts():
    subprocess.run(['pkill', '-f', 'chopper.sh'])
    subprocess.run(['pkill', '-f', 'obit.sh'])
    subprocess.run(['pkill', '-f', 'connect.sh'])
    subprocess.run(['pkill', '-f', 'discon.sh'])

def reader():
    while True:
        with open('/root/Zomboid/server-console.txt', 'r') as file:
            for line in file:
                end_of_line = re.search(r'command\sentered\svia\sserver\sconsole\s\(System\.in\):\s\"quit\"', line)
                if end_of_line:
                    title = "Server shutdown initiated. Server going down **NOW**"
                    uptime = get_server_uptime()
                    message = f"The Server was up for {uptime}"

                    send_discord_message(ORANGE, title, message)
                    stop_monitoring_scripts()
                    return

if __name__ == '__main__':
    reader()
