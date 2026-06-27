#!/bin/bash
echo "Setup Server"
termux-wake-lock
termux-setup-storage
pkg upgrade -y
pkg install termux-services
sleep 3

echo "Installing Server"
pkg install openssh -y && pkg install proot-distro -y
sleep 3

proot-distro install debian
proot-distro login debian << 'EOF'

apt update && apt upgrade -y
apt install build-essential sudo wget curl vim nano net-tools iputils-ping procps adduser ca-certificates gnupg unzip zip htop tzdata -y
sleep 3

apt install nginx sqlite3 mariadb-server -y
apt install nodejs npm python3 python3-pip golang php-cli php-fpm luajit -y
sleep 3

wget -O /usr/local/bin/gitea https://dl.gitea.com/gitea/1.22.1/gitea-1.22.1-linux-arm64
chmod +x /usr/local/bin/gitea
sleep 3

mkdir -p /var/www/Project/Dev{1..10}
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
cat << '_NGINX_' > /etc/nginx/sites-available/default
server {
    listen 6000 default_server;

    root /var/www/Project;

    index index.html index.htm;

    location / {
        autoindex on;
        autoindex_exact_size off;
        autoindex_localtime on;

        try_files $uri $uri/ =404;
    }

    location ~* \.(html|css|js|png|jpg|jpeg|gif|ico)$ {
        expires -1;
        add_header Cache-Control "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0";
    }
}
_NGINX_
sleep 3

echo "setup admin user"
adduser admin
exit
curl -fsSL
curl -fsSL
EOF
sleep 3

curl -fsSL "https://raw.githubusercontent.com/CoffeAfterBreak/VPS-On-android/main/start.sh" -o ~/start.sh
chmod +x ~/start.sh
clear
echo "setup SSH"
passwd
whoami
echo "this name will be used when you try SSH it"
sshd
sleep 6

echo "================================================================"
echo "                SETUP COMPLETED SUCCESSFULLY!                   "
echo "================================================================"
echo ""
echo "CRITICAL: Pay close attention to WHERE you run each script!"
echo ""
echo "1. TO START THE SERVERS (Run this in OUTER TERMUX ONLY):"
echo "   Command: ./start.sh"
echo "   -> Location: Outer Termux environment (before logging into Debian)."
echo "   -> Effect: Launches SSH, triggers Nginx, Filebrowser, and Gitea"
echo "              in the background, then drops you into Debian."
echo ""
echo "2. TO RESTART SERVICES (Run this INSIDE DEBIAN PROOT ONLY):"
echo "   Command: ./restart.sh"
echo "   -> Location: Inside your Debian PRoot terminal session."
echo "   -> Effect: Reloads Nginx configs and cleanly restarts"
echo "              Filebrowser and Gitea after you upload new files."
echo ""
echo "3. TO KILL ALL SERVICES (Run this INSIDE DEBIAN PROOT ONLY):"
echo "   Command: ./stop.sh"
echo "   -> Location: Inside your Debian PRoot terminal session."
echo "   -> Effect: Safely forces Nginx to stop and kills all background"
echo "              processes (Gitea, Filebrowser, Node, Python3)."
echo ""
echo "================================================================"
