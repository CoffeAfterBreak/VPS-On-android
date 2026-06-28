#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Installing PrivateBin (Pastebin)...${NC}"

# ============================================================
# INSTALL PRIVATEBIN
# ============================================================

proot-distro login debian << 'DEBIAN_EOF'
export DEBIAN_FRONTEND=noninteractive

echo "Installing PrivateBin"
apt-get update > /dev/null 2>&1

# Download latest PrivateBin
PRIVATEBIN_DIR="/var/www/privatebin"
mkdir -p $PRIVATEBIN_DIR
cd /tmp
curl -fsSL https://github.com/PrivateBin/PrivateBin/releases/download/1.6.2/PrivateBin-1.6.2-php.zip -o privatebin.zip
unzip -q privatebin.zip -d $PRIVATEBIN_DIR
rm privatebin.zip

# Set permissions
chmod -R 755 $PRIVATEBIN_DIR
chown -R admin:admin $PRIVATEBIN_DIR

echo "PrivateBin installed at $PRIVATEBIN_DIR"

DEBIAN_EOF

# ============================================================
# PATCH CADDYFILE (reverse proxy for /paste)
# ============================================================

if ! grep -q "reverse_proxy /paste" /home/admin/Caddyfile; then
    echo "Patching Caddyfile for PrivateBin..."
    
    # Insert reverse proxy before file_server (localhost is used for local reverse proxy)
    sed -i '/file_server browse/i\    reverse_proxy /paste localhost:9002' /home/admin/Caddyfile
fi

# ============================================================
# PATCH start.sh
# ============================================================

if ! grep -q "PrivateBin" /home/admin/start.sh; then
    echo "Patching start.sh..."
    
    sed -i '/# EXTENSION SERVICES/i\
echo "start privatebin"\
nohup php -S 0.0.0.0:9002 -t /var/www/privatebin > /dev/null 2>&1 &' /home/admin/start.sh
fi

# ============================================================
# PATCH stop.sh
# ============================================================

if ! grep -q "privatebin" /home/admin/stop.sh; then
    echo "Patching stop.sh..."
    
    sed -i '/# EXTENSION SERVICES/i\
echo "stop privatebin"\
pkill -f "php -S 0.0.0.0:9002"' /home/admin/stop.sh
fi

# ============================================================
# PATCH restart.sh (both stop and start sections)
# ============================================================

if ! grep -q "privatebin" /home/admin/restart.sh; then
    echo "Patching restart.sh..."
    
    # Add to stop section
    sed -i '/# EXTENSION SERVICES STOP/i\
pkill -f "php -S 0.0.0.0:9002"' /home/admin/restart.sh
    
    # Add to start section
    sed -i '/# EXTENSION SERVICES START/i\
echo "start privatebin"\
nohup php -S 0.0.0.0:9002 -t /var/www/privatebin > /dev/null 2>&1 &' /home/admin/restart.sh
fi

# ============================================================
# DONE
# ============================================================

echo -e "${GREEN}✓ PrivateBin installation complete${NC}"
echo ""
echo "Access PrivateBin at:"
echo "  http://localhost:3000/paste"
echo ""
echo "Control scripts updated:"
echo "  • start.sh - added PrivateBin startup (PHP on 0.0.0.0:9002)"
echo "  • stop.sh - added PrivateBin stop"
echo "  • restart.sh - added PrivateBin restart"
echo ""
echo "Next: Run './restart.sh' to start PrivateBin"
