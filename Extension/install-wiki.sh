#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Installing Wiki.js (Documentation Wiki)...${NC}"

# ============================================================
# INSTALL WIKI.JS
# ============================================================

echo "Installing Wiki.js via npm..."

proot-distro login debian << 'DEBIAN_EOF'
export DEBIAN_FRONTEND=noninteractive

echo "Installing Wiki.js globally"
npm install -g wiki.js > /dev/null 2>&1

# Create wiki directory
mkdir -p /opt/wiki
cd /opt/wiki

# Initialize Wiki.js
npx wiki-js init > /dev/null 2>&1

chmod -R 755 /opt/wiki
chown -R admin:admin /opt/wiki

echo "Wiki.js installed at /opt/wiki"

DEBIAN_EOF

# ============================================================
# PATCH Caddyfile (reverse proxy for Wiki.js on port 3001)
# ============================================================

if ! grep -q "reverse_proxy /wiki" /home/admin/Caddyfile; then
    echo "Patching Caddyfile for Wiki.js..."
    
    sed -i '/file_server browse/i\    reverse_proxy /wiki localhost:3001' /home/admin/Caddyfile
fi

# ============================================================
# PATCH start.sh
# ============================================================

if ! grep -q "wiki.js" /home/admin/start.sh; then
    echo "Patching start.sh..."
    
    sed -i '/# EXTENSION SERVICES/i\
echo "start wiki.js"\
cd /opt/wiki && nohup wiki-js start > /dev/null 2>&1 &' /home/admin/start.sh
fi

# ============================================================
# PATCH stop.sh
# ============================================================

if ! grep -q "wiki.js" /home/admin/stop.sh; then
    echo "Patching stop.sh..."
    
    sed -i '/# EXTENSION SERVICES/i\
echo "stop wiki.js"\
pkill -f "wiki-js start"' /home/admin/stop.sh
fi

# ============================================================
# PATCH restart.sh
# ============================================================

if ! grep -q "wiki.js" /home/admin/restart.sh; then
    echo "Patching restart.sh..."
    
    # Add to stop section
    sed -i '/# EXTENSION SERVICES STOP/i\
pkill -f "wiki-js start"' /home/admin/restart.sh
    
    # Add to start section
    sed -i '/# EXTENSION SERVICES START/i\
echo "start wiki.js"\
cd /opt/wiki && nohup wiki-js start > /dev/null 2>&1 &' /home/admin/restart.sh
fi

# ============================================================
# DONE
# ============================================================

echo -e "${GREEN}✓ Wiki.js installation complete${NC}"
echo ""
echo "Access Wiki.js at:"
echo "  Direct: http://localhost:3001"
echo "  Via Caddy: http://localhost:3000/wiki"
echo ""
echo "Control scripts updated:"
echo "  • start.sh - added Wiki.js startup"
echo "  • stop.sh - added Wiki.js stop"
echo "  • restart.sh - added Wiki.js restart"
echo ""
echo "First run setup:"
echo "  1. Run './restart.sh' to start Wiki.js"
echo "  2. Visit http://localhost:3001"
echo "  3. Create admin account"
echo "  4. Configure wiki"
echo ""
echo "Note: First startup may take 30-60 seconds"
