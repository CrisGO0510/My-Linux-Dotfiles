#!/usr/bin/env bash

# Lee los atajos directamente del compositor (hyprctl binds -j) en vez de
# parsear la config: asi funciona con la config en Lua, donde muchos binds se
# generan en bucles y no existen como lineas de texto.

font="JetBrainsMono Nerd Font 10"
rofiConf="$HOME/.config/rofi/keybinds.rasi"

# Anchura de la columna de teclas, para que queden alineadas.
KEY_COLUMN_WIDTH=25

if pgrep -x "rofi" > /dev/null; then
    pkill rofi
    exit 0
fi

if ! binds=$(hyprctl binds -j 2>/dev/null); then
    notify-send "Error" "No se pudieron consultar los atajos a Hyprland"
    exit 1
fi

# Bits de modmask de Hyprland: Shift 1, Ctrl 4, Alt 8, Super 64.
jq_script='
    def bit($m; $b): (($m / $b) | floor) % 2 == 1;
    def mods($m):
        [ (if bit($m;64) then "Super" else empty end),
          (if bit($m;4)  then "Ctrl"  else empty end),
          (if bit($m;8)  then "Alt"   else empty end),
          (if bit($m;1)  then "Shift" else empty end) ];
    def prettyKey($k):
        if   $k == "slash"  then "/"
        elif $k == "Return" then "Enter"
        else $k end;
    def caption:
        if (.description // "") != "" then .description
        else (.dispatcher + (if (.arg // "") != "" then " " + .arg else "" end)) end;

    .[]
    | select((.key // "") != "")
    | (mods(.modmask) + [prettyKey(.key)] | join(" + ")) + "\t" + caption
'

printf '%s' "$binds" | jq -r "$jq_script" | \
    while IFS=$'\t' read -r keys desc; do
        printf '<b>%-*s</b>  │  %s\n' "$KEY_COLUMN_WIDTH" "$keys" "$desc"
    done | \
rofi -dmenu \
    -i \
    -markup-rows \
    -p "Atajos" \
    -config "$rofiConf" \
    -font "$font"
