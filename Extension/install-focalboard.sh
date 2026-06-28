#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Installing Focalboard (Project Management)...${NC}"

# ============================================================
# INSTALL FOCALBOARD
# ============================================================

proot-distro login debian << 'DEBIAN_EOF'
export DEBIAN_FRONTEND=noninteractive

echo "Downloading Focalboard"
FOCALBOARD_DIR="/opt/focalboard"
mkdir -p $FOCALBOARD_DIR

cd /tmp
# Download latest Focalboard for Linux ARM64
curl -fsSL https://releases.mattermost.com/focalboard/v7.11.2/focalboard-server-linux-amd64.tar.gz -o focalboard.tar.gz
tar -xzf focalboard.tar.gz -C $FOCALBOARD_DIR
rm focalboard.tar.gz

# Create data directory
mkdir -p $FOCALBOARD_DIR/data
chmod -R 755 $FOCALBOARD_DIR
chown -R admin:admin $FOCALBOARD_DIR

echo "Focalboard installed at $FOCALBOARD_DIR"

DEBIAN_EOF

# ============================================================
# PATCH Caddyfile (reverse proxy for /focalboard)
# ============================================================

if ! grep -q "reverse_proxy /focalboard" /home/admin/Caddyfile; then
    echo "Patching Caddyfile for Focalboard..."
    
    sed -i '/file_server browse/i\    reverse_proxy /focalboard localhost:8000' /home/admin/Caddyfile
fi

# ============================================================
# PATCH start.sh
# ============================================================

if ! grep -q "focalboard" /home/admin/start.sh; then
    echo "Patching start.sh..."
    
    sed -i '/# EXTENSION SERVICES/i\
echo "start focalboard"\
nohup /opt/focalboard/bin/focalboard-server > /dev/null 2>&1 &\
sleep 2' /home/admin/start.sh
fi

# ============================================================
# PATCH stop.sh
# ============================================================

if ! grep -q "focalboard" /home/admin/stop.sh; then
    echo "Patching stop.sh..."
    
    sed -i '/# EXTENSION SERVICES/i\
echo "stop focalboard"\
pkill -f "focalboard-server"' /home/admin/stop.sh
fi

# ============================================================
# PATCH restart.sh
# ============================================================

if ! grep -q "focalboard" /home/admin/restart.sh; then
    echo "Patching restart.sh..."
    
    # Add to stop section
    sed -i '/# EXTENSION SERVICES STOP/i\
pkill -f "focalboard-server"' /home/admin/restart.sh
    
    # Add to start section
    sed -i '/# EXTENSION SERVICES START/i\
echo "start focalboard"\
nohup /opt/focalboard/bin/focalboard-server > /dev/null 2>&1 &\
sleep 2' /home/admin/restart.sh
fi

# ============================================================
# DONE
# ============================================================

echo -e "${GREEN}✓ Focalboard installation complete${NC}"
echo ""
echo "Access Focalboard at:"
echo "  Direct: http://localhost:8000"
echo "  Via Caddy: http://localhost:3000/focalboard"
echo ""
echo "Control scripts updated:"
echo "  • start.sh - added Focalboard startup"
echo "  • stop.sh - added Focalboard stop"
echo "  • restart.sh - added Focalboard restart"
echo ""
echo "First run setup:"
echo "  1. Run './restart.sh' to start Focalboard"
echo "  2. Visit http://localhost:8000"
echo "  3. Create admin account"
echo "  4. Create workspace"
echo ""
echo "Note: First startup may take 30 seconds"
