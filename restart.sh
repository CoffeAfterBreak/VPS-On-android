#!/bin/bash
nginx -s reload
pkill -f "filebrowser"
pkill -f "gitea"
su - admin -c "nohup filebrowser -r / -p 5000 -a 0.0.0.0 > /dev/null 2>&1 &"
su - admin -c "nohup env GITEA__server__HTTP_PORT=5050 /usr/local/bin/gitea web > /dev/null 2>&1 &"
