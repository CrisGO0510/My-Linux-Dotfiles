#!/bin/bash

# Detectar qué monitor usar (argumento opcional o detección automática)
if [ "$1" ]; then
    monitor_id="$1"
else
    monitor_id=$(~/.config/eww/scripts/monitor-detect.sh)
fi

if [ "$monitor_id" = "1" ]; then
    # Monitor 1 (secundario)
    if [[ -z $(eww active-windows | grep 'usrctl_1') ]]; then
        /usr/bin/eww open usrctl_1 && /usr/bin/eww update ctlrev_1=true
    else
        /usr/bin/eww update ctlrev_1=false
        (sleep 0.2 && /usr/bin/eww close usrctl_1) &
    fi
else
    # Monitor 0 (principal)
    if [[ -z $(eww active-windows | grep 'usrctl') ]]; then
        /usr/bin/eww open usrctl && /usr/bin/eww update ctlrev=true
    else
        /usr/bin/eww update ctlrev=false
        (sleep 0.2 && /usr/bin/eww close usrctl) &
    fi
fi
