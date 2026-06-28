#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Installing PM2 (Node.js Process Manager)...${NC}"

# ============================================================
# INSTALL PM2
# ============================================================

echo "Installing PM2 globally..."
npm install -g pm2 > /dev/null 2>&1

# Create PM2 ecosystem config
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
        NODE_ENV: "production"
      },
      watch: false,
      max_memory_restart: "256M"
      // Add more apps here as needed
    }
  ]
};
ECOSYSTEM_EOF

chmod 644 /home/admin/pm2/ecosystem.config.js
chown admin:admin /home/admin/pm2/ecosystem.config.js

# ============================================================
# PATCH start.sh
# ============================================================

if ! grep -q "pm2" /home/admin/start.sh; then
    echo "Patching start.sh..."
    
    sed -i '/# EXTENSION SERVICES/i\
echo "start pm2 apps"\
pm2 start /home/admin/pm2/ecosystem.config.js > /dev/null 2>&1' /home/admin/start.sh
fi

# ============================================================
# PATCH stop.sh
# ============================================================

if ! grep -q "pm2" /home/admin/stop.sh; then
    echo "Patching stop.sh..."
    
    sed -i '/# EXTENSION SERVICES/i\
echo "stop pm2 apps"\
pm2 stop all > /dev/null 2>&1' /home/admin/stop.sh
fi

# ============================================================
# PATCH restart.sh
# ============================================================

if ! grep -q "pm2" /home/admin/restart.sh; then
    echo "Patching restart.sh..."
    
    # Add to stop section
    sed -i '/# EXTENSION SERVICES STOP/i\
pm2 stop all > /dev/null 2>&1' /home/admin/restart.sh
    
    # Add to start section
    sed -i '/# EXTENSION SERVICES START/i\
echo "start pm2 apps"\
pm2 start /home/admin/pm2/ecosystem.config.js > /dev/null 2>&1' /home/admin/restart.sh
fi

# ============================================================
# DONE
# ============================================================

echo -e "${GREEN}✓ PM2 installation complete${NC}"
echo ""
echo "PM2 Configuration:"
echo "  Config file: /home/admin/pm2/ecosystem.config.js"
echo ""
echo "Control scripts updated:"
echo "  • start.sh - added PM2 startup"
echo "  • stop.sh - added PM2 stop"
echo "  • restart.sh - added PM2 restart"
echo ""
echo "How to use PM2:"
echo ""
echo "  1. Edit /home/admin/pm2/ecosystem.config.js"
echo "  2. Add your Node.js app entry:"
echo ""
echo "     apps: ["
echo "       {"
echo "         name: 'myapp',"
echo "         script: 'app.js',"
echo "         cwd: '/path/to/app'"
echo "       }"
echo "     ]"
echo ""
echo "  3. Run './restart.sh' to start apps"
echo ""
echo "PM2 Commands:"
echo "  pm2 status          - Show all apps"
echo "  pm2 logs            - View logs"
echo "  pm2 save            - Save config"
echo "  pm2 startup         - Auto-start on boot"
echo "  pm2 delete all      - Stop all apps"
echo ""
echo "Note: PM2 will auto-restart crashed apps"
