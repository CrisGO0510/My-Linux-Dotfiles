#!/usr/bin/env bash
# Devuelve la ruta de la caratula del audio/video actual para el widget
# image de hyprlock. Si no hay reproductor o caratula, cae al avatar.

fallback="$HOME/dotfiles/assets/hoshino_ai.png"
art="$(playerctl metadata mpris:artUrl 2>/dev/null)"

case "$art" in
    file://*)
        path="${art#file://}"
        [ -f "$path" ] && printf '%s' "$path" || printf '%s' "$fallback"
        ;;
    http://*|https://*)
        tmp="/tmp/hypr-lock-art"
        if curl -sf --max-time 6 "$art" -o "$tmp" 2>/dev/null; then
            printf '%s' "$tmp"
        else
            printf '%s' "$fallback"
        fi
        ;;
    *)
        printf '%s' "$fallback"
        ;;
esac
