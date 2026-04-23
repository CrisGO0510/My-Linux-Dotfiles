#!/bin/bash

# Toggle o consultar el estado de sshd
case "$1" in
    toggle)
        if systemctl is-active --quiet sshd; then
            sudo systemctl stop sshd
        else
            sudo systemctl start sshd
        fi
        # Actualizar variable en eww
        if systemctl is-active --quiet sshd; then
            /usr/bin/eww update ssh_active=true
        else
            /usr/bin/eww update ssh_active=false
        fi
        ;;
    *)
        # Consultar estado actual
        if systemctl is-active --quiet sshd; then
            echo "true"
        else
            echo "false"
        fi
        ;;
esac
