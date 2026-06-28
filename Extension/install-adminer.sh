#!/bin/bash

# Install Adminer - Single PHP file GUI for SQLite and MariaDB
# Serves from FileBrowser web root

echo "Installing Adminer (Database GUI)..."

proot-distro login debian << 'EOF'

echo "Download Adminer"
curl -fsSL https://adminer.org/latest.php -o /var/www/Project/adminer.php

echo "Set permissions"
chmod 644 /var/www/Project/adminer.php
chown admin:admin /var/www/Project/adminer.php

echo "Adminer installed"

EOF

echo "✓ Adminer installation complete"
echo ""
echo "Access Adminer (Database GUI) at:"
echo "  http://localhost/adminer.php"
echo ""
echo "Login:"
echo "  System: SQLite OR MySQL"
echo "  Database file: /var/lib/sqlite/[your-db].db (for SQLite)"
echo "  Server: localhost (for MariaDB)"
echo "  User: root / Password: (if MariaDB is running)"
