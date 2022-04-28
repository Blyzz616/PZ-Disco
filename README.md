**# PZ-Disco**
Discord integration for Project Zomboid

**Requirements**
Ok, So this needs to be run on the instance that is running the Project Zomboid server.
Obviously the OS needs to be Linux with Bourne Again Shell (BASH) and a few other dependencies, listed later.
You'll also have to have your own Discord Server (or have admin rights to the server) to get a Webhook set up.
This script assumes that you have installed the Zomboid server to the default location and the settings are in the /root/Zomboid/ subdirectories.

This script should only be run AFTER the script that initiates the Zomboid server is run:

_Running the scripts:_

1. start zomboid server with start.sh
2. start overseer.sh - **AS ROOT**
3. start obit.sh - **AS ROOT**

_File list:_

- start.sh - starts the server in a screen instance so that it will not be closed accidentally.
- overseer.sh - reads the server output line per line and reacts accordingly.
- obit.sh - read a different log file and puts in any deaths that happen on the server.

_Installation:_

Open a terminal to your server and make sure that all the dependencies are installed:

```
sudo apt update -y && sudo apt upgrade -y
sudo apt install curl screen sed awk grep tail
```

All of these are installed by default on most distros.
Now create the files for the scripts.

```
sudo mkdir -p /user/local/bin/boid
sudo touch /usr/local/bin/boid/overseer.sh /usr/local/bin/boid/obit.sh
sudo chmod ug+x /usr/local/bin/boid/overseer.sh /usr/local/bin/boid/obit.sh
```

Open overseer.sh in your favourite editor (nano/vim/etc) and paste in the overseer.sh stuff.

**IMPORTANT:** You need to insert your own Discord Webhook at the top of the file.

Save and close

Then do the same for obit.sh

Make sure that your Webhook has all the correct access to your Discord server

To start the Zomboid server manually, I keep a script in /home/boid/, but you can have yours wherever you want. I also have a bunch of different server settings and use different scripts to start them.

If you want to do it like me, you'll need to create a start.sh in your home directory

```
touch ~/start.sh
cd ~
sudo chown root:root start.sh
sudo chmod ug+x start.sh
```

Now copy, paste the start.sh code in there

_Running the scripts:_

Start your server

```
cd ~
sudo ./start.sh
sudo cd /usr/local/bin/boid
sudo ./obit.sh &
sudo ./overseer.sh &
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
@reboot         tail -Fn0 /root/Zomboid/server-console.txt
```

If you have a monitor plugged into your server and you want to use it to watch the raw PZ output like me, change the 2nd line above to:

```
@reboot         tail -Fn0 /root/Zomboid/server-console.txt > /dev/tty1
```



_Payoff:_

Now join your Project Zomboid server and watch discord for all the glory.
