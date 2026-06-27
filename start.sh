#!/bin/bash
passwd
whoami
sshd
proot-distro login debian -- bash -c '
    su - admin
    service nginx start
    nohup filebrowser -r /var/www/Project -p 5000 -a 0.0.0.0 > /dev/null 2>&1 &
    nohup env GITEA__server__HTTP_PORT=5050 /usr/local/bin/gitea web > /dev/null 2>&1 &
'
