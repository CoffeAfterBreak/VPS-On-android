echo "stop php-fpm"
service php-fpm stop > /dev/null 2>&1
echo "stop caddy"
pkill -f caddy
echo "stop filebrowser"
pkill -f filebrowser
echo "stop gitea"
pkill -f gitea
echo "stop redis"
pkill -f redis-server
echo "stop redis-commander"
pkill -f redis-commander
echo "stop ssh"
service ssh stop > /dev/null 2>&1
echo "exit"
kill -9 $PPID
