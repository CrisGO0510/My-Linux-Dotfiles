#!/usr/bin/env bash

# Pega la imagen del portapapeles local en una terminal SSH a la otra máquina.
# Sube la imagen por scp y pega su ruta remota: Claude Code adjunta la imagen al recibir la ruta.

case "$(hostnamectl hostname)" in
    pc)     peer=laptop ;;
    laptop) peer=pc ;;
    *)
        notify-send -a "Imagen remota" "Hostname desconocido" "No sé cuál es la otra máquina desde $(hostnamectl hostname)"
        exit 1
        ;;
esac

if ! wl-paste --list-types | grep -qx 'image/png'; then
    notify-send -a "Imagen remota" "No hay imagen en el portapapeles"
    exit 1
fi

tmp=$(mktemp --suffix=.png)
trap 'rm -f "$tmp"' EXIT
wl-paste --type image/png > "$tmp"

# Ruta relativa al home remoto; se borran las de más de un día para no acumular
remote_dir=.cache/remote-img
remote_file="$remote_dir/$(date +%Y%m%d_%H%M%S).png"

if ! ssh -o BatchMode=yes "$peer" "mkdir -p $remote_dir && find $remote_dir -name '*.png' -mtime +1 -delete" \
    || ! scp -q -o BatchMode=yes "$tmp" "$peer:$remote_file"; then
    notify-send -a "Imagen remota" "No se pudo subir a $peer"
    exit 1
fi

# La ruta reemplaza la imagen en el portapapeles y se pega en la ventana enfocada
printf '%s' "/home/$USER/$remote_file" | wl-copy
hyprctl dispatch 'hl.dsp.send_shortcut({ mods = "CTRL SHIFT", key = "V" })' > /dev/null
