#!/usr/bin/env bash

# Abre una terminal kitty conectada por SSH (Tailscale) a la otra máquina.
# Los nombres son los de MagicDNS y deben coincidir con el hostname de cada equipo.

case "$(hostnamectl hostname)" in
    pc)     peer=laptop ;;
    laptop) peer=pc ;;
    *)
        notify-send -a "Terminal remota" "Hostname desconocido" "No sé cuál es la otra máquina desde $(hostnamectl hostname)"
        exit 1
        ;;
esac

# Sin esta comprobación, si el otro equipo está apagado se abre y cierra una ventana vacía
if ! timeout 3 bash -c "</dev/tcp/$peer/22" 2>/dev/null; then
    notify-send -a "Terminal remota" "$peer no disponible" "No responde por Tailscale (¿apagado o sin tailscaled?)"
    exit 1
fi

exec kitty kitten ssh "$peer"
