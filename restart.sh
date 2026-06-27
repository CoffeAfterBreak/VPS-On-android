echo "stop server"
pkill -f caddy
pkill -f filebrowser
pkill -f gitea
echo "start caddy"
nohup caddy run --config /home/admin/Caddyfile > /dev/null 2>&1 &
echo "start filebrowser"
nohup filebrowser -d /home/admin/filebrowser.db > /dev/null 2>&1 &
echo "start gitea"
nohup env GITEA__server__HTTP_PORT=5000 /usr/local/bin/gitea web > /dev/null 2>&1 &
