#!/bin/zsh

# git update-index --assume-unchanged Scripts/globalProtect.sh
# Variables de usuario
USER="cristhian.giraldo1"
PASS="cristhian0510"

# Conectar a VPN
echo $PASS | sudo openconnect --protocol=gp --user=$USER --passwd-on-stdin intra.utp.edu.co
