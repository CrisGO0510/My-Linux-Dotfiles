#!/bin/bash

# Script de detección de monitor para EWW
# Detecta en qué monitor está el cursor y retorna el número de monitor

# Obtener posición del cursor
cursor_pos=$(hyprctl cursorpos)

# Extraer coordenadas X e Y
x_pos=$(echo "$cursor_pos" | cut -d',' -f1)
y_pos=$(echo "$cursor_pos" | cut -d',' -f2 | tr -d ' ')

# Obtener información de monitores
monitors_info=$(hyprctl monitors -j)

# Determinar en qué monitor está el cursor
monitor_id=0

# Monitor 0 (DP-3): 0-1919 en X
# Monitor 1 (HDMI-A-1): 1920+ en X
if [ "$x_pos" -ge 1920 ]; then
    monitor_id=1
fi

echo "$monitor_id"