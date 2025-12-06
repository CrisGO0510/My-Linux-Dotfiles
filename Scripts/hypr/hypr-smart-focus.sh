#!/usr/bin/env bash
dir="$1"
is_full=$(hyprctl -j activewindow | jq -r '.fullscreen' 2>/dev/null)

if [[ "$is_full" == "2" ]]; then
  case "$dir" in
    h) hyprctl dispatch cyclenext ;;
    l) hyprctl dispatch cyclenext ;;
    k) hyprctl dispatch cyclenext prev;;
    j) hyprctl dispatch cyclenext prev;;
  esac
else
  # No fullscreen: usa direcciones reales
  case "$dir" in
    h) hyprctl dispatch movefocus l ;;
    l) hyprctl dispatch movefocus r ;;
    k) hyprctl dispatch movefocus u ;;
    j) hyprctl dispatch movefocus d ;;
  esac
fi

