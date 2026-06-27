echo "setup"
termux-wake-lock
termux-setup-storage
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y -o Dpkg::Options::="--force-confold"
echo "install termux package"
pkg install termux-services openssh proot-distro -y
sleep 1
echo "install debian"
if [ ! -d "$PREFIX/var/lib/proot-distro/installed-rootfs/debian" ]; then
    proot-distro install debian
fi
proot-distro login debian << 'EOF'
export DEBIAN_FRONTEND=noninteractive
echo "mariadb-server-10.5 mysql-server/start_on_boot boolean false" | debconf-set-selections
apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"
echo "install debian package"
apt install build-essential sudo wget curl vim nano net-tools iputils-ping procps ca-certificates gnupg unzip zip htop tzdata -y
apt install sqlite3 mariadb-server nodejs npm python3 python3-pip golang php-cli php-fpm luajit -y
sleep 1
echo "create admin"
if ! id -u admin >/dev/null 2>&1; then
    useradd -m -s /bin/bash admin
fi
echo "download gitea"
wget -O /usr/local/bin/gitea https://dl.gitea.com/gitea/1.22.1/gitea-1.22.1-linux-arm64
chmod +x /usr/local/bin/gitea
echo "download filebrowser"
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
echo "setup filebrowser"
mkdir -p /home/admin
filebrowser config init -d /home/admin/filebrowser.db
filebrowser config set -d /home/admin/filebrowser.db --address 0.0.0.0 --port 5000 --root /home/admin
filebrowser users add admin "admin12345678" --perm.admin=true -d /home/admin/filebrowser.db 2>/dev/null || filebrowser users update admin --password "admin12345678" -d /home/admin/filebrowser.db
echo "download caddy"
wget -O /usr/local/bin/caddy "https://caddyserver.com/api/download?os=linux&arch=arm64"
chmod +x /usr/local/bin/caddy
echo "setup directory"
mkdir -p /var/www/Project/Dev{1..10}
cat << '_CADDY_' > /home/admin/Caddyfile
:6000 {
    root * /var/www/Project
    file_server browse
}
_CADDY_
echo "create start script"
curl -fsSL "https://raw.githubusercontent.com/CoffeAfterBreak/VPS-On-android/main/start.sh" -o /home/admin/start.sh
echo "start caddy"
nohup caddy run --config /home/admin/Caddyfile > /dev/null 2>&1 &
echo "start filebrowser"
nohup filebrowser -d /home/admin/filebrowser.db > /dev/null 2>&1 &
echo "start gitea"
nohup env GITEA__server__HTTP_PORT=5050 /usr/local/bin/gitea web > /dev/null 2>&1 &
_START_
echo "create restart script"
curl -fsSL "https://raw.githubusercontent.com/CoffeAfterBreak/VPS-On-android/main/restart.sh" -o /home/admin/restart.sh
echo "stop server"
pkill -f caddy
pkill -f filebrowser
pkill -f gitea
echo "start caddy"
nohup caddy run --config /home/admin/Caddyfile > /dev/null 2>&1 &
echo "start filebrowser"
nohup filebrowser -d /home/admin/filebrowser.db > /dev/null 2>&1 &
echo "start gitea"
nohup env GITEA__server__HTTP_PORT=5050 /usr/local/bin/gitea web > /dev/null 2>&1 &
_RESTART_
echo "create stop script"
curl -fsSL "https://raw.githubusercontent.com/CoffeAfterBreak/VPS-On-android/main/stop.sh" -o /home/admin/stop.sh
echo "stop caddy"
pkill -f caddy
echo "stop filebrowser"
pkill -f filebrowser
echo "stop gitea"
pkill -f gitea
echo "exit"
kill -9 $PPID
_STOP_
echo "apply permission"
chmod +x /home/admin/start.sh /home/admin/restart.sh /home/admin/stop.sh
chown -R admin:admin /var/www/Project
chown -R admin:admin /home/admin
EOF
clear
echo "done"
