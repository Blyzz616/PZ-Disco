import requests
import re
import os

# Replace this with your Discord webhook URL
URL = ''

# Color constant
LIME = 65280

# Replace this with your Discord webhook URL
URL = ''

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

def server_started():
    start_var = "SERVER STARTED"
    with open(' ZOMDIR/server-console.txt', 'r') as file:
        for line in file:
            if re.search(start_var, line):
                # Send timestamp to tmp file
                with open('/tmp/srvr-start.time', 'w') as tmp_file:
                    tmp_file.write(str(int(time.time())))

                with open('/tmp/srvr-up.time', 'r') as up_file:
                    rising = int(up_file.read().strip())
                risen = int(time.time())
                rise_secs = risen - rising

                # Assuming you have "servername" in the process name
                server_name = os.popen("ps aux | grep 'servername' | grep -v grep | grep Project | awk '{print $NF}'").read().strip()
                with open(f' ZOMDIR/{server_name}.up', 'w') as server_up_file:
                    server_up_file.write(f"{time.strftime('%c')} {server_name} {rise_secs}\n")

                if rise_secs >= 60:
                    rise_time = f"{rise_secs // 60}m {rise_secs % 60}s"
                else:
                    rise_time = f"{rise_secs}s"

                title = "Server is now **ONLINE**"
                message = f"Server took {rise_time} to come online."
                send_discord_message(LIME, title, message)
                break

if __name__ == '__main__':
    server_started()
