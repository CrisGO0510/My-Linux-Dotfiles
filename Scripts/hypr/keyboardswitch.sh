#!/usr/bin/env sh

hyprctl switchxkblayout all next

layMain=$(hyprctl -j devices | jq '.keyboards' | jq '.[] | select (.main == true)' | awk -F '"' '{if ($2=="active_keymap") print $4}')

# reutiliza el id anterior para reemplazar la notificación en vez de apilarla
id_file="${XDG_RUNTIME_DIR:-/tmp}/keyboardswitch.id"
prev=$(cat "$id_file" 2>/dev/null)
notify-send -p -a "Teclado" -r "${prev:-0}" -t 1500 "${layMain}" > "$id_file"
