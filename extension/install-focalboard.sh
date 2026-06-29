#!/bin/bash

proot-distro login debian << 'DEBIAN_EOF'
export DEBIAN_FRONTEND=noninteractive

FOCALBOARD_DIR="/opt/focalboard"
mkdir -p $FOCALBOARD_DIR

cd /tmp
curl -fsSL https://releases.mattermost.com/focalboard/v7.11.2/focalboard-server-linux-amd64.tar.gz -o focalboard.tar.gz
tar -xzf focalboard.tar.gz -C $FOCALBOARD_DIR
rm focalboard.tar.gz

mkdir -p $FOCALBOARD_DIR/data
chmod -R 755 $FOCALBOARD_DIR
chown -R admin:admin $FOCALBOARD_DIR

cat > $FOCALBOARD_DIR/config.json << 'CONFIG_EOF'
{
  "server": {
    "port": 5600,
    "address": "0.0.0.0",
    "useSSL": false,
    "webPath": "./",
    "fileMaxSize": 268435456
  },
  "logging": {
    "development": false,
    "logLevel": "info"
  },
  "sqlite": {
    "dbPath": "./data/focalboard.db"
  }
}
CONFIG_EOF

chown admin:admin $FOCALBOARD_DIR/config.json
DEBIAN_EOF

# Add reverse proxy to Caddyfile if not exists
if ! grep -q "reverse_proxy /focalboard" /home/admin/Caddyfile; then
    sed -i '/file_server browse/i\    reverse_proxy /focalboard 0.0.0.0:5600' /home/admin/Caddyfile
fi

# Add Focalboard to start.sh
if ! grep -q "focalboard-server" /home/admin/start.sh; then
    sed -i '/# EXTENSION SERVICES/i nohup /opt/focalboard/bin/focalboard-server > /dev/null 2>&1 &' /home/admin/start.sh
fi

# Add Focalboard to stop.sh
if ! grep -q "focalboard-server" /home/admin/stop.sh; then
    sed -i '/# EXTENSION SERVICES/i pkill -f "focalboard-server"' /home/admin/stop.sh
fi

# Add Focalboard to restart.sh
if ! grep -q "focalboard-server" /home/admin/restart.sh; then
    sed -i '/# EXTENSION SERVICES STOP/i pkill -f "focalboard-server"' /home/admin/restart.sh
    sed -i '/# EXTENSION SERVICES START/i nohup /opt/focalboard/bin/focalboard-server > /dev/null 2>&1 &' /home/admin/restart.sh
fi

echo "✓ Focalboard installed at /opt/focalboard"
echo "  Access: http://<router-ip>:5600 or http://<tailscale-ip>:5600"
echo "  Config: /opt/focalboard/config.json"
