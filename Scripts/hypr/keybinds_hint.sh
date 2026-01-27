#!/usr/bin/env bash

# -----------------------------------------------------
# 1. CONFIGURACIÓN Y COLORES (TUS COLORES)
# -----------------------------------------------------
confDir="${XDG_CONFIG_HOME:-$HOME/.config}"
font="JetBrainsMono Nerd Font 10"

# Buscamos tu archivo de keybindings
if [ -f "$confDir/hypr/keybinding.conf" ]; then
    keyconf="$confDir/hypr/keybinding.conf"
elif [ -f "$confDir/hypr/keybindings.conf" ]; then
    keyconf="$confDir/hypr/keybindings.conf"
else
    keyconf="$confDir/hypr/hyprland.conf"
fi

# -----------------------------------------------------
# 2. LÓGICA DE DATOS (EXTRAER ATAJOS)
# -----------------------------------------------------

if pgrep -x "rofi" > /dev/null; then
    pkill rofi
    exit 0
fi

if [ ! -f "$keyconf" ]; then
    notify-send "Error" "No config found"
    exit 1
fi

awk_script='
BEGIN { FS=","; }
/bind/ && /#/ {
    line = $0;
    
    # Separar comentario
    split(line, parts, "#");
    desc = parts[2];
    code = parts[1];
    
    # Limpiar espacios
    gsub(/^\s+|\s+$/, "", desc);
    gsub(/bind[a-z]*\s*=\s*/, "", code);
    
    # Separar teclas
    split(code, args, ",");
    mod = args[1];
    key = args[2];
    
    gsub(/^\s+|\s+$/, "", mod);
    gsub(/^\s+|\s+$/, "", key);
    
    # Formato visual de teclas
    gsub(/\$mainMod/, "SUPER", mod);
    gsub(/SHIFT/, "Shift", mod);
    gsub(/CTRL/, "Ctrl", mod);
    gsub(/ALT/, "Alt", mod);
    gsub(/slash/, "/", key);
    gsub(/Return/, "Enter", key);
    
    # Solo mostrar si hay tecla definida
    if (key != "") {
        if (mod != "") {
            keys = mod " + " key;
        } else {
            keys = key;
        }
        
        # Salida formateada con Pango Markup
        # %-25s reserva espacio fijo para las teclas para que se vean como columnas
        printf "<b>%-25s</b>  │  %s\n", keys, desc
    }
}'

# -----------------------------------------------------
# 3. EJECUCIÓN
# -----------------------------------------------------

awk "$awk_script" "$keyconf" | \
rofi -dmenu \
    -i \
    -markup-rows \
    -p "Atajos" \
    -config "$HOME/.config/rofi/keybinds.rasi" \
    -font "$font"
