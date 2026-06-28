#!/bin/bash

echo "stop server"
pkill -f php
pkill -f caddy
pkill -f filebrowser
pkill -f gitea
service ssh stop > /dev/null 2>&1

# EXTENSION SERVICES STOP - Auto-added by install scripts below this line
# DO NOT EDIT MANUALLY - Extensions will patch this section

echo "start php"
nohup php -S 0.0.0.0:9001 -t /var/www/Project > /dev/null 2>&1 &
echo "start caddy"
nohup caddy run --config /home/admin/Caddyfile > /dev/null 2>&1 &
echo "start filebrowser"
nohup filebrowser -d /home/admin/filebrowser.db > /dev/null 2>&1 &
echo "start gitea"
nohup env GITEA__server__HTTP_PORT=5000 /usr/local/bin/gitea web > /dev/null 2>&1 &
echo "start ssh"
service ssh start > /dev/null 2>&1

# EXTENSION SERVICES START - Auto-added by install scripts below this line
# DO NOT EDIT MANUALLY - Extensions will patch this section
