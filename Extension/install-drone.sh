#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Installing Drone (CI/CD Pipeline)...${NC}"

# ============================================================
# INSTALL DRONE
# ============================================================

proot-distro login debian << 'DEBIAN_EOF'
export DEBIAN_FRONTEND=noninteractive

echo "Installing Drone Server"
DRONE_DIR="/opt/drone"
mkdir -p $DRONE_DIR
cd /tmp

# Download Drone Server for Linux ARM64
curl -fsSL https://github.com/harness/drone/releases/download/v2.21.2/drone_linux_arm64.tar.gz -o drone.tar.gz
tar -xzf drone.tar.gz -C $DRONE_DIR
rm drone.tar.gz

# Create data directory
mkdir -p $DRONE_DIR/data
chmod -R 755 $DRONE_DIR
chown -R admin:admin $DRONE_DIR

# Create Drone config
cat > $DRONE_DIR/drone-config.env << 'CONFIG_EOF'
DRONE_SERVER_HOST=localhost:8080
DRONE_SERVER_PROTO=http
DRONE_RPC_SECRET=your-secret-key-change-this
DRONE_GITEA_SERVER=http://localhost:5000
DRONE_GITEA_CLIENT_ID=drone-client
DRONE_GITEA_CLIENT_SECRET=drone-secret
CONFIG_EOF

echo "Drone installed at $DRONE_DIR"

DEBIAN_EOF

# ============================================================
# PATCH Caddyfile (reverse proxy for Drone)
# ============================================================

if ! grep -q "reverse_proxy /drone" /home/admin/Caddyfile; then
    echo "Patching Caddyfile for Drone..."
    
    sed -i '/file_server browse/i\    reverse_proxy /drone localhost:8080' /home/admin/Caddyfile
fi

# ============================================================
# PATCH start.sh
# ============================================================

if ! grep -q "drone" /home/admin/start.sh; then
    echo "Patching start.sh..."
    
    sed -i '/# EXTENSION SERVICES/i\
echo "start drone"\
cd /opt/drone && nohup ./drone-server > /dev/null 2>&1 &\
sleep 2' /home/admin/start.sh
fi

# ============================================================
# PATCH stop.sh
# ============================================================

if ! grep -q "drone" /home/admin/stop.sh; then
    echo "Patching stop.sh..."
    
    sed -i '/# EXTENSION SERVICES/i\
echo "stop drone"\
pkill -f "drone-server"' /home/admin/stop.sh
fi

# ============================================================
# PATCH restart.sh
# ============================================================

if ! grep -q "drone" /home/admin/restart.sh; then
    echo "Patching restart.sh..."
    
    # Add to stop section
    sed -i '/# EXTENSION SERVICES STOP/i\
pkill -f "drone-server"' /home/admin/restart.sh
    
    # Add to start section
    sed -i '/# EXTENSION SERVICES START/i\
echo "start drone"\
cd /opt/drone && nohup ./drone-server > /dev/null 2>&1 &\
sleep 2' /home/admin/restart.sh
fi

# ============================================================
# DONE
# ============================================================

echo -e "${GREEN}✓ Drone installation complete${NC}"
echo ""
echo "Access Drone at:"
echo "  Direct: http://localhost:8080"
echo "  Via Caddy: http://localhost:3000/drone"
echo ""
echo "Control scripts updated:"
echo "  • start.sh - added Drone startup"
echo "  • stop.sh - added Drone stop"
echo "  • restart.sh - added Drone restart"
echo ""
echo "IMPORTANT - Configuration:"
echo "  1. Edit /opt/drone/drone-config.env"
echo "  2. Set DRONE_RPC_SECRET to a random string"
echo "  3. Configure Gitea integration:"
echo "     - Go to Gitea Settings → Applications"
echo "     - Create OAuth app for Drone"
echo "     - Update DRONE_GITEA_CLIENT_ID and CLIENT_SECRET"
echo ""
echo "First run setup:"
echo "  1. Run './restart.sh' to start Drone"
echo "  2. Visit http://localhost:8080"
echo "  3. Authorize with Gitea"
echo "  4. Enable repositories for CI/CD"
echo ""
echo "Note: First startup may take 30 seconds"
