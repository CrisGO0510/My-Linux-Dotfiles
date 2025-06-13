#!/usr/bin/env bash

selected_wall="${1:-}"
lockFile="/tmp/$(basename "${0}").lock"

if [ -e "${lockFile}" ]; then
    cat <<EOF

Error: Another instance of $(basename "${0}") is running.
If you are sure that no other instance is running, remove the lock file:
    ${lockFile}
EOF
    exit 1
fi

touch "${lockFile}"
trap 'rm -f "${lockFile}"' EXIT

# Configuración local
WALLPAPER_SWWW_TRANSITION_DEFAULT="grow"
wallFramerate=60
wallTransDuration=0.4

# Verifica wallpaper
if [ -z "${selected_wall}" ] || [ ! -f "${selected_wall}" ]; then
    echo "[ERROR] No valid wallpaper provided."
    exit 1
fi

# Iniciar swww si no está activo
if ! swww query &>/dev/null; then
    swww-daemon --format xrgb &
    disown
    sleep 0.5 # Le damos un pequeño tiempo para iniciar
fi

# Obtener posición del cursor si hyprctl está disponible
if command -v hyprctl &>/dev/null; then
    cursorPos="$(hyprctl cursorpos | grep -E '^[0-9]' || echo "0,0")"
else
    cursorPos="0,0"
fi

# Aplicar wallpaper
echo "[INFO] Applying wallpaper: $(readlink -f "${selected_wall}")"
swww img "$(readlink -f "${selected_wall}")" \
    --transition-bezier .43,1.19,1,.4 \
    --transition-type "${WALLPAPER_SWWW_TRANSITION_DEFAULT}" \
    --transition-duration "${wallTransDuration}" \
    --transition-fps "${wallFramerate}" \
    --invert-y \
    --transition-pos "${cursorPos}" &

exit 0
