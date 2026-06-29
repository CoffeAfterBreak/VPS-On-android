#!/bin/bash

npm install -g pm2 > /dev/null 2>&1

mkdir -p /home/admin/pm2
cat > /home/admin/pm2/ecosystem.config.js << 'ECOSYSTEM_EOF'
module.exports = {
  apps: [
    {
      name: "my-app",
      script: "./app.js",
      cwd: "/var/www/Project",
      instances: 1,
      exec_mode: "cluster",
      env: {
        NODE_ENV: "production",
        PORT: "5100"
      },
      watch: false,
      max_memory_restart: "256M"
    }
  ]
};
ECOSYSTEM_EOF

chmod 644 /home/admin/pm2/ecosystem.config.js
chown admin:admin /home/admin/pm2/ecosystem.config.js

grep -q "pm2" /home/admin/start.sh || \
sed -i '/# EXTENSION SERVICES/i\
pm2 start /home/admin/pm2/ecosystem.config.js > /dev/null 2>&1' /home/admin/start.sh

grep -q "pm2" /home/admin/stop.sh || \
sed -i '/# EXTENSION SERVICES/i\
pm2 stop all > /dev/null 2>&1' /home/admin/stop.sh

grep -q "pm2" /home/admin/restart.sh || {
sed -i '/# EXTENSION SERVICES STOP/i\
pm2 stop all > /dev/null 2>&1' /home/admin/restart.sh
sed -i '/# EXTENSION SERVICES START/i\
pm2 start /home/admin/pm2/ecosystem.config.js > /dev/null 2>&1' /home/admin/restart.sh
}

echo "PM2 installed"
echo "Port: 5100+ (sesuaikan di ecosystem.config.js)"
echo "Edit /home/admin/pm2/ecosystem.config.js dan set PORT env untuk setiap app"
