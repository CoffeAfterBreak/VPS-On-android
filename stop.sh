#!/bin/bash

echo "stop php"
nohup php -S 0.0.0.0:9001 -t /var/www/Project > /dev/null 2>&1 &
echo "stop caddy"
pkill -f caddy
echo "stop filebrowser"
pkill -f filebrowser
echo "stop gitea"
pkill -f gitea
echo "stop ssh"
service ssh stop > /dev/null 2>&1

# EXTENSION SERVICES - Auto-added by install scripts below this line
# DO NOT EDIT MANUALLY - Extensions will patch this section

echo "exit"
kill -9 $PPID
