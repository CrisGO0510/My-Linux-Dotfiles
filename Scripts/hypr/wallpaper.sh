#!/usr/bin/env bash

DOTFILES="$HOME/dotfiles/assets"
WALL="$DOTFILES/ds_tanjiro.jpg"

killall hyprpaper 2>/dev/null
sleep 0.2

cat > /tmp/hyprpaper.conf <<EOF
preload = $WALL
splash = false
EOF

hyprpaper -c /tmp/hyprpaper.conf &

sleep 0.5

for MON in $(hyprctl monitors -j | jq -r '.[].name'); do
    hyprctl hyprpaper wallpaper "$MON,$WALL"
done
