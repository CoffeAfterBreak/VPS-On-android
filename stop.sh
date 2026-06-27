#!/bin/bash
pkill sshd
proot-distro login debian -- bash -c '
    service nginx stop
    pkill -f "filebrowser"
    pkill -f "gitea"
    pkill -f "node"
    pkill -f "python3"
'
