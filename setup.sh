#!/bin/bash
echo "=== STARTING FRESH SERVER SETUP ==="
termux-wake-lock
termux-setup-storage

# Prevent Termux upgrade from prompting you with interactive configuration questions
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y -o Dpkg::Options::="--force-confold"

echo "Installing Core Termux Tools..."
pkg install termux-services openssh proot-distro -y
sleep 1

echo "Installing Debian PRoot Environment..."
if [ ! -d "$PREFIX/var/lib/proot-distro/installed-rootfs/debian" ]; then
    proot-distro install debian
fi

# Entering Debian to perform all inner configurations
proot-distro login debian << 'EOF'

# Prevent Debian packages from prompting you with interactive screens
export DEBIAN_FRONTEND=noninteractive

# CRITICAL FIX: Tell MariaDB to not try and start background daemons during apt install
echo "mariadb-server-10.5 mysql-server/start_on_boot boolean false" | debconf-set-selections

apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"

echo "Installing Utilities and Languages..."
apt install build-essential sudo wget curl vim nano net-tools iputils-ping procps ca-certificates gnupg unzip zip htop tzdata -y
apt install sqlite3 mariadb-server nodejs npm python3 python3-pip golang php-cli php-fpm luajit -y
sleep 1

echo "Setting up admin user directory..."
if ! id -u admin >/dev/null 2>&1; then
    useradd -m -s /bin/bash admin
fi

echo "Downloading Gitea Server Binary..."
# Fixed to point to stable global delivery binary URL
wget -O /usr/local/bin/gitea https://dl.gitea.com/gitea/1.22.1/gitea-1.22.1-linux-arm64
chmod +x /usr/local/bin/gitea

echo "Downloading Filebrowser Binary..."
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

echo "Initializing Filebrowser Database and Setting Password..."
mkdir -p /home/admin
# CRITICAL FIX: Explicitly bind the database path flag during configuration creation
filebrowser config init -d /home/admin/filebrowser.db
filebrowser config set -d /home/admin/filebrowser.db --address 0.0.0.0 --port 5000 --root /
filebrowser users add admin "admin12345678" --perm.admin=true -d /home/admin/filebrowser.db 2>/dev/null || filebrowser users update admin --password "admin12345678" -d /home/admin/filebrowser.db

echo "Downloading Caddy Server (Replacing Nginx)..."
wget -O /usr/local/bin/caddy "https://caddyserver.com/api/download?os=linux&arch=arm64"
chmod +x /usr/local/bin/caddy

echo "Creating Project Directories..."
mkdir -p /var/www/Project/Dev{1..10}
chown -R admin:admin /var/www/Project
chown -R admin:admin /home/admin/filebrowser.db

echo "Configuring Caddy Server..."
cat << '_CADDY_' > /root/Caddyfile
:6000 {
    root * /var/www/Project
    file_server browse
}
_CADDY_

EOF
sleep 1

clear
echo "================================================================"
echo "         INITIAL CORE SETUP COMPLETED SUCCESSFULLY!             "
echo "================================================================"
echo ""
echo " Your phone environment is prepared with the absolute roots for:"
echo " -> Caddy Web Server (Port 6000)"
echo " -> Filebrowser (Port 5000) -> Pass: admin12345678"
echo " -> Gitea Engine (Port 5050)"
echo ""
echo "================================================================"
