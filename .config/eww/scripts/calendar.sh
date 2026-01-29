#!/bin/bash

# Detectar qué monitor usar (argumento opcional o detección automática)
if [ "$1" ]; then
    monitor_id="$1"
else
    monitor_id=$(~/.config/eww/scripts/monitor-detect.sh)
fi

if [ "$monitor_id" = "1" ]; then
    # Monitor 1 (secundario)
    if [[ -z $(eww active-windows | grep 'calendar_1') ]]; then
        /usr/bin/eww open calendar_1 && /usr/bin/eww update calrev_1=true
    else
        /usr/bin/eww update calrev_1=false
        (sleep 0.2 && /usr/bin/eww close calendar_1) &
    fi
else
    # Monitor 0 (principal)
    if [[ -z $(eww active-windows | grep 'calendar') ]]; then
        /usr/bin/eww open calendar && /usr/bin/eww update calrev=true
    else
        /usr/bin/eww update calrev=false
        (sleep 0.2 && /usr/bin/eww close calendar) &
    fi
fi
