#!/bin/bash
service nginx stop
pkill -f "filebrowser"
pkill -f "gitea"
pkill -f "node"
pkill -f "python3"
