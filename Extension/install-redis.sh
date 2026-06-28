#!/bin/bash

# Install Redis (In-memory cache) and redis-commander (GUI)
# Run this AFTER setup.sh completes

echo "Installing Redis and redis-commander..."

proot-distro login debian << 'EOF'
export DEBIAN_FRONTEND=noninteractive

echo "install redis-server"
apt-get update
apt install redis-server -y

echo "install redis-commander (GUI for Redis)"
npm install -g redis-commander

echo "redis-server ready to start"
echo "redis-commander will run on port 8081"

EOF

echo "✓ Redis installation complete"
echo ""
echo "Redis will be started automatically when you run start.sh"
echo "Access Redis GUI at: http://localhost:8081"
