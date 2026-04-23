#!/bin/bash

# Detectar qué monitor usar (argumento opcional o detección automática)
if [ "$1" ]; then
    monitor_id="$1"
else
    monitor_id=$(~/.config/eww/scripts/monitor-detect.sh)
fi

if [ "$monitor_id" = "1" ]; then
    # Monitor 1 (secundario)
    if [[ -z $(eww active-windows | grep 'menuctl_1') ]]; then
        /usr/bin/eww open menuctl_1 && /usr/bin/eww update menurev_1=true
    else
        /usr/bin/eww update menurev_1=false
        (sleep 0.2 && /usr/bin/eww close menuctl_1) &
    fi
else
    # Monitor 0 (principal)
    if [[ -z $(eww active-windows | grep 'menuctl') ]]; then
        /usr/bin/eww open menuctl && /usr/bin/eww update menurev=true
    else
        /usr/bin/eww update menurev=false
        (sleep 0.2 && /usr/bin/eww close menuctl) &
    fi
fi
