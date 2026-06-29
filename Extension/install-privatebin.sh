#!/bin/bash

proot-distro login debian << 'DEBIAN_EOF'
export DEBIAN_FRONTEND=noninteractive
apt-get update > /dev/null 2>&1

PRIVATEBIN_DIR="/var/www/privatebin"
mkdir -p $PRIVATEBIN_DIR
cd /tmp
curl -fsSL https://github.com/PrivateBin/PrivateBin/releases/download/1.6.2/PrivateBin-1.6.2-php.zip -o privatebin.zip
unzip -q privatebin.zip -d $PRIVATEBIN_DIR
rm privatebin.zip

chmod -R 755 $PRIVATEBIN_DIR
chown -R admin:admin $PRIVATEBIN_DIR
DEBIAN_EOF

grep -q "reverse_proxy /paste" /home/admin/Caddyfile || \
sed -i '/file_server browse/i\    reverse_proxy /paste 0.0.0.0:5500' /home/admin/Caddyfile

grep -q "PrivateBin" /home/admin/start.sh || \
sed -i '/# EXTENSION SERVICES/i\
nohup php -S 0.0.0.0:5500 -t /var/www/privatebin > /dev/null 2>&1 &' /home/admin/start.sh

grep -q "privatebin" /home/admin/stop.sh || \
sed -i '/# EXTENSION SERVICES/i\
pkill -f "php -S 0.0.0.0:5500"' /home/admin/stop.sh

grep -q "privatebin" /home/admin/restart.sh || {
sed -i '/# EXTENSION SERVICES STOP/i\
pkill -f "php -S 0.0.0.0:5500"' /home/admin/restart.sh
sed -i '/# EXTENSION SERVICES START/i\
nohup php -S 0.0.0.0:5500 -t /var/www/privatebin > /dev/null 2>&1 &' /home/admin/restart.sh
}

echo "PrivateBin installed at /var/www/privatebin"
echo "Access: http://<router-ip>:5500 atau http://<tailscale-ip>:5500"
