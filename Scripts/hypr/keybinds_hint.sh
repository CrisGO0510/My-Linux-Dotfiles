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
# Usamos tus colores exactos, pero forzamos una estructura de lista simple.
# main-bg: #161925ff (Fondo)
# main-fg: #c74dedff (Texto principal/Prompt)
# main-br: #f9dc5cff (Borde Amarillo)
# select-bg: #ed254eff (Rojo Selección)

read -r -d '' r_theme << EOM
* {
    /* Tus Colores */
    bg:         #161925ff;
    fg:         #e0def4;     /* Blanco suave para texto normal */
    accent:     #c74dedff;   /* Tu main-fg (Morado) */
    border:     #f9dc5cff;   /* Tu main-br (Amarillo) */
    sel-bg:     #ed254eff;   /* Tu select-bg (Rojo) */
    sel-fg:     #ffffff;     /* Blanco para texto seleccionado */

    background-color:   @bg;
    text-color:         @fg;
}

window {
    width:              60%;     /* Ancho perfecto */
    border:             2px;
    border-color:       @border;
    border-radius:      10px;
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
