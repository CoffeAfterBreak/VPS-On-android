#!/bin/bash

termux-wake-lock
termux-setup-storage
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade -y -o Dpkg::Options::="--force-confold"
pkg install termux-services openssh proot-distro -y
sleep 1

if [ ! -d "$PREFIX/var/lib/proot-distro/installed-rootfs/debian" ]; then
    proot-distro install debian
fi

proot-distro login debian << 'EOF'
export DEBIAN_FRONTEND=noninteractive
echo "mariadb-server-10.5 mysql-server/start_on_boot boolean false" | debconf-set-selections
apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"

apt install build-essential sudo wget curl vim nano net-tools iputils-ping procps ca-certificates gnupg unzip zip htop tzdata -y
apt install sqlite3 mariadb-server nodejs npm python3 python3-pip golang php-cli php-fpm luajit -y
sleep 1

if ! id -u admin >/dev/null 2>&1; then
    useradd -m -s /bin/bash admin
fi

wget -O /usr/local/bin/gitea https://dl.gitea.com/gitea/1.22.1/gitea-1.22.1-linux-arm64
chmod +x /usr/local/bin/gitea

curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

mkdir -p /home/admin
filebrowser config init -d /home/admin/filebrowser.db
filebrowser config set -d /home/admin/filebrowser.db --address 0.0.0.0 --port 3000 --root /
filebrowser users add admin "admin12345678" --perm.admin=true -d /home/admin/filebrowser.db 2>/dev/null || filebrowser users update admin --password "admin12345678" -d /home/admin/filebrowser.db

curl -L -o /usr/local/bin/caddy_temp.tar.gz "https://github.com/caddyserver/caddy/releases/download/v2.8.4/caddy_2.8.4_linux_arm64.tar.gz"
tar -xf /usr/local/bin/caddy_temp.tar.gz -C /usr/local/bin/ caddy
rm -f /usr/local/bin/caddy_temp.tar.gz
chmod +x /usr/local/bin/caddy

mkdir -p /var/www/Project/Dev{1..10}
cat << '_CADDY_' > /home/admin/Caddyfile
:2000 {
    root * /var/www/Project
    php_fastcgi localhost:9000
    file_server browse
}
_CADDY_

curl -fsSL "https://raw.githubusercontent.com/CoffeAfterBreak/VPS-On-android/main/start.sh" -o /home/admin/start.sh
curl -fsSL "https://raw.githubusercontent.com/CoffeAfterBreak/VPS-On-android/main/restart.sh" -o /home/admin/restart.sh
curl -fsSL "https://raw.githubusercontent.com/CoffeAfterBreak/VPS-On-android/main/stop.sh" -o /home/admin/stop.sh

chmod +x /home/admin/start.sh /home/admin/restart.sh /home/admin/stop.sh
chown -R admin:admin /var/www/Project
chown -R admin:admin /home/admin

EOF

clear
echo "Setup complete"
