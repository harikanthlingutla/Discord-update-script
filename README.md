# Discord-update-script

Update discord on linux systems automagically with this script.
To use this script:

Save it as discord-updater.sh

Make it executable:

chmod +x discord-updater.sh

Run it with sudo:

sudo ./discord-updater.sh
To make it run automatically, you can set up a cron job. Here's how:

Open the crontab editor:

sudo crontab -e

Add this line to run it daily at 3 AM:

0 3 * * * /path/to/discord-updater.sh
The script:

Logs all actions to /var/log/discord-updater.log
Checks if Discord is running and closes it if necessary
Downloads the latest version from Discord's official server
Compares versions and only installs if there's an update
Handles dependencies automatically
Cleans up temporary files

You can check the logs anytime with:
udo tail -f /var/log/discord-updater.log
