#!/usr/bin/env bash

# Obtener nombre del primer monitor
MONITOR=$(hyprctl monitors | grep "Monitor" | head -n 1 | awk '{print $2}')

# Ruta base de los dotfiles (usa $HOME para que no dependa del usuario)
DOTFILES="$HOME/dotfiles/assets"

# Generar hyprpaper.conf temporal
cat > /tmp/hyprpaper.conf <<EOF
preload = $DOTFILES/cyan_magenta.png
preload = $DOTFILES/eyes.png
wallpaper = $MONITOR,$DOTFILES/eyes.png
EOF

# Matar cualquier instancia previa
killall hyprpaper 2>/dev/null

# Iniciar hyprpaper con el conf generado
hyprpaper -c /tmp/hyprpaper.conf &
