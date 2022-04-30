
![What the discord integration looks like](https://i.imgur.com/Xa4TcU1.jpeg)

**# PZ-Disco**
Discord integration for Project Zomboid

**Requirements**
Ok, So this needs to be run on the instance that is running the Project Zomboid server.
Obviously the OS needs to be Linux with Bourne Again Shell (BASH) and a few other dependencies, listed later.
You'll also have to have your own Discord Server (or have admin rights to the server) to get a Webhook set up.
This script assumes that you have installed the Zomboid server to the default location and the settings are in the /root/Zomboid/ subdirectories.

_Running the scripts:_

1. start zomboid server with start.sh **AS ROOT**

_File list:_

- start.sh - starts the server in a screen instance so that it will not be closed accidentally
- startup.sh - Announces when the server has finised starting up and can accept connections
- connect.sh
  - Announces when a player joins a server and keeps a record of it in /root/users.log (one line per user)
  - Keeps a record of failed join attempts in /root/denied.log
  - Keeps a record of when people joined the server in /root/access.log (one line per join)
- discon.sh - Annonces when a player leaves the server both when they quit or lose conneciton
- chopper.sh - Announces the different states of the chopper event (with some fun random messages)
- obit.sh - read a different log file and puts in any deaths that happen on the server
- shutdown.sh - Annonces when the server is being taken down with a server-up timer

_Installation:_

Open a terminal to your server and make sure that all the dependencies are installed:

```
sudo apt update -y && sudo apt upgrade -y
sudo apt install curl screen sed grep
```

All of these are installed by default on most distros.
Now create the directory for the scripts.

```
sudo mkdir -p /user/local/bin/boid
```

All of the scripts except for start.sh go in there

Be sure to set the permissions

```
chown root:root /usr/local/bin/boid/*.sh
chmod ug+x /usr/local/bin/boid/*.sh
```

**IMPORTANT:** You need to insert your own Discord Webhook at the top of _ALL_ of the files.

Make sure that your Webhook has all the correct access to your Discord server

To start the Zomboid server manually, I keep the start.sh in /home/boid/, but you can have yours wherever you want. I also have a bunch of different server settings and use different scripts to start them. (slocan.sh to start the Slocan Lake map, and knox.sh to start the Knox county map etc)

Now save the start.sh file to your home directory (I've got mine in /home/boid/)
You'll want to edit that one up too. There are 3 things in there that need editing:

1. Add your Discord Webhook URL
2. Change the server start-up message
3. Change the SRVRINI variable to your own server settings name.

_Running the scripts:_

Start your server

```
cd ~
sudo ./start.sh
```

**CAUTION!** Running multiple instances of these scripts WILL cause duplicated output in discord.

_Added Extra:_
I include cronjobs to do this all for me

```
sudo crontab -e
```

addthe following lines

```
@reboot         /home/boid/start.sh > /dev/null 2
```

If you have a monitor plugged into your server and you want to use it to watch the raw PZ output like me, add this line as well:

```
@reboot         tail -Fn0 /root/Zomboid/server-console.txt > /dev/tty1
```



_Payoff:_

Now join your Project Zomboid server and watch discord for all the glory.
