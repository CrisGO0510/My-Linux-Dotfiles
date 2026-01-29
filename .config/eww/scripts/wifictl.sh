#!/bin/bash

# Detectar qué monitor usar (argumento opcional o detección automática)
if [ "$1" ]; then
    monitor_id="$1"
else
    monitor_id=$(~/.config/eww/scripts/monitor-detect.sh)
fi

if [ "$monitor_id" = "1" ]; then
    # Monitor 1 (secundario)
    if [[ -z $(eww active-windows | grep 'wifictl_1') ]]; then
        /usr/bin/eww open wifictl_1 && /usr/bin/eww update wifictlrev_1=true
    else
        /usr/bin/eww update wifictlrev_1=false && /usr/bin/eww update wificonfigrev_1=false
        (sleep 0.2 && /usr/bin/eww close wifictl_1) &
    fi
else
    # Monitor 0 (principal)
    if [[ -z $(eww active-windows | grep 'wifictl') ]]; then
        /usr/bin/eww open wifictl && /usr/bin/eww update wifictlrev=true
    else
        /usr/bin/eww update wifictlrev=false && /usr/bin/eww update wificonfigrev=false
        (sleep 0.2 && /usr/bin/eww close wifictl) &
    fi
fi
