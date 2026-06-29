#!/bin/bash

nohup php -S 0.0.0.0:5001 -t /var/www/Project > /dev/null 2>&1 &
nohup caddy run --config /home/admin/Caddyfile > /dev/null 2>&1 &
nohup filebrowser -d /home/admin/filebrowser.db > /dev/null 2>&1 &
nohup env GITEA__server__HTTP_PORT=4000 /usr/local/bin/gitea web > /dev/null 2>&1 &
service ssh start > /dev/null 2>&1

# EXTENSION SERVICES
