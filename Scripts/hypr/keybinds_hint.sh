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

# AQUÍ DEFINIMOS EL TEMA VISUAL DESDE CERO
# Usamos los colores de Azure Dreams para consistencia visual
# main-bg: #0f0f23ff (Fondo)
# main-fg: #ddd6feff (Texto principal)
# main-br: #4fd1c7ff (Borde Turquesa)
# select-bg: #a29bfeff (Lavanda Selección)

read -r -d '' r_theme << EOM
* {
    /* Azure Dreams Color Scheme */
    bg:         #0f0f23ff;   /* Deep navy background */
    fg:         #ddd6feff;   /* Purple-tinted white text */
    accent:     #6c5ce7ff;   /* Modern vibrant purple */
    border:     #4fd1c7ff;   /* Turquoise accent border */
    sel-bg:     #a29bfeff;   /* Soft lavender selection */
    sel-fg:     #0f0f23ff;   /* Dark text on light selection */

    background-color:   @bg;
    text-color:         @fg;
}

window {
    width:              60%;     /* Ancho perfecto */
    border:             2px;
    border-color:       @border;
    border-radius:      16px;    /* Consistent with Azure Dreams theme */
    padding:            20px;
    background-color:   @bg;
}

inputbar {
    children:           [ prompt, entry ];
    background-color:   @bg;
    padding:            0px 0px 15px 0px;
}

prompt {
    background-color:   @accent;
    text-color:         @bg;
    padding:            5px 10px;
    border-radius:      5px;
    margin:             0 10px 0 0;
    font:               "${font} bold";
}

entry {
    background-color:   @bg;
    text-color:         @fg;
    placeholder:        "Buscar...";
    padding:            5px;
}

listview {
    columns:            1;
    lines:              12;
    background-color:   @bg;
    scrollbar:          false;
    layout:             vertical;
    spacing:            5px;
}

/* LA CLAVE: Limpiamos el elemento para que solo tenga texto */
element {
    orientation:        horizontal;
    children:           [ element-text ];
    padding:            8px 10px;
    border-radius:      5px;
    background-color:   transparent;
}

element selected {
    background-color:   @sel-bg;
    text-color:         @sel-fg;
}

element-text {
    horizontal-align:   0.0; /* ALINEACIÓN A LA IZQUIERDA FORZADA */
    vertical-align:     0.5;
    background-color:   inherit;
    text-color:         inherit;
}
EOM

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

# Pasamos la variable $r_theme directamente a rofi
echo "$r_theme" > /tmp/rofi_keybinds.rasi

awk "$awk_script" "$keyconf" | \
rofi -dmenu \
    -i \
    -markup-rows \
    -p "Atajos" \
    -config "/tmp/rofi_keybinds.rasi" \
    -font "$font"
