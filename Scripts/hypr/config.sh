#!/usr/bin/env bash
# Minimal configuration replacement for globalcontrol.sh
# Only essential variables for remaining scripts (cliphist.sh)
# Hyde-free configuration

export confDir="${XDG_CONFIG_HOME:-$HOME/.config}"
export rofiScale=10

# Hyprland border detection (for cliphist.sh rofi positioning)
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    export hypr_border="$(hyprctl -j getoption decoration:rounding | jq '.int' 2>/dev/null || echo 5)"
    export hypr_width="$(hyprctl -j getoption general:border_size | jq '.int' 2>/dev/null || echo 2)"
else
    export hypr_border=5
    export hypr_width=2
fi