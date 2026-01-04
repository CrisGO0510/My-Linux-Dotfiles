#!/usr/bin/env bash
dir="$1"

# 1. Obtener la info de la ventana activa
active_window=$(hyprctl activewindow -j)
# Capturamos el tipo de fullscreen: 0:none, 1:real, 2:maximized
is_full=$(echo "$active_window" | jq -r '.fullscreen')

if [[ "$is_full" != "0" && "$is_full" != "null" ]]; then
    # 2. Si estamos en fullscreen, movemos el foco
    case "$dir" in
        h|k) hyprctl dispatch cyclenext prev ;;
        l|j) hyprctl dispatch cyclenext ;;
    esac

    hyprctl dispatch fullscreen "$is_full"
else
    # Modo normal (tiled): mover foco tradicional
    case "$dir" in
        h) hyprctl dispatch movefocus l ;;
        l) hyprctl dispatch movefocus r ;;
        k) hyprctl dispatch movefocus u ;;
        j) hyprctl dispatch movefocus d ;;
    esac
fi
