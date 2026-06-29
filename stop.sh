#!/bin/bash

pkill -f "php -S"
pkill -f caddy
pkill -f filebrowser
pkill -f gitea
service ssh stop > /dev/null 2>&1

# EXTENSION SERVICES

kill -9 $PPID
