echo "stop caddy"
pkill -f caddy
echo "stop filebrowser"
pkill -f filebrowser
echo "stop gitea"
pkill -f gitea
echo "exit"
kill -9 $PPID
