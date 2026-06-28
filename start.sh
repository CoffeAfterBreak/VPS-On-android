echo "start php-fpm"
service php-fpm start > /dev/null 2>&1
echo "start caddy"
nohup caddy run --config /home/admin/Caddyfile > /dev/null 2>&1 &
echo "start filebrowser"
nohup filebrowser -d /home/admin/filebrowser.db > /dev/null 2>&1 &
echo "start gitea"
nohup env GITEA__server__HTTP_PORT=5000 /usr/local/bin/gitea web > /dev/null 2>&1 &
echo "start redis"
nohup redis-server --port 6379 --appendonly no > /dev/null 2>&1 &
echo "start ssh"
service ssh start > /dev/null 2>&1
echo "start redis-commander (DB GUI)"
nohup redis-commander --port 8081 > /dev/null 2>&1 &
