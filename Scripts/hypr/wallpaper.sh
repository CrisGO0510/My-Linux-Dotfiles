#!/usr/bin/env bash

# Wallpaper Script with Rofi Sync
# Now automatically generates images for Rofi Azure Dreams theme

DOTFILES="$HOME/dotfiles/assets"
WALL="/home/cris/dotfiles/assets/eyes.png"

# Rofi sync paths
ROFI_TEMP_DIR="/tmp/rofi_wallpapers"
ROFI_MAIN="$ROFI_TEMP_DIR/wall_main.jpg"
ROFI_BLUR="$ROFI_TEMP_DIR/wall_blur.jpg"

echo "🎨 Setting wallpaper and syncing with Rofi..."

# Create temp directory for Rofi images
mkdir -p "$ROFI_TEMP_DIR"

# Kill existing hyprpaper
killall hyprpaper 2>/dev/null
sleep 0.2

# Generate Rofi images from current wallpaper
if [ -f "$WALL" ]; then
    echo "📸 Generating Rofi background images..."
    
    # Main wallpaper for dummywall background
    cp "$WALL" "$ROFI_MAIN"
    
    # Blurred version for mode-switcher (with resize for performance)
    convert "$WALL" \
        -blur 0x8 \
        -resize 600x400^ \
        -gravity center \
        -extent 600x400 \
        "$ROFI_BLUR" 2>/dev/null
    
    echo "✅ Rofi images generated:"
    echo "   Main: $ROFI_MAIN"
    echo "   Blur: $ROFI_BLUR"
else
    echo "⚠️  Warning: Wallpaper not found at $WALL"
fi

# Configure hyprpaper
cat > /tmp/hyprpaper.conf <<EOF
preload = $WALL
splash = false
EOF

echo "🖼️  Starting hyprpaper..."
hyprpaper -c /tmp/hyprpaper.conf &

sleep 0.5

# Apply wallpaper to all monitors
echo "🖥️  Applying to monitors..."
for MON in $(hyprctl monitors -j | jq -r '.[].name'); do
    hyprctl hyprpaper wallpaper "$MON,$WALL"
    echo "   Applied to: $MON"
done

echo "🎉 Wallpaper sync complete! Rofi will now use the same background."
