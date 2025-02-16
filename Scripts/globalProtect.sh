#!/bin/zsh

# git update-index --assume-unchanged Scripts/globalProtect.sh
# Variables de usuario
USER="user"
PASS="user"

# Conectar a VPN
echo $PASS | sudo openconnect --protocol=gp --user=$USER --passwd-on-stdin intra.utp.edu.co
