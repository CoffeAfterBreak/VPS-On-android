#!/bin/bash
proot-distro login debian -- bash -c '
    nginx -s reload
    pkill -f "filebrowser"
    pkill -f "gitea"
    nohup filebrowser -r /var/www/Project -p 5000 -a 0.0.0.0 > /dev/null 2>&1 &
    nohup env GITEA__server__HTTP_PORT=5050 /usr/local/bin/gitea web > /dev/null 2>&1 &
'
