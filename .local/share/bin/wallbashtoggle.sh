#!/usr/bin/env sh

# Set local variables
scrDir="$(dirname "$(realpath "$0")")"
rofiConf="$HOME/.config/rofi/wallbash.rasi"  # Ajusta la ruta si es diferente
wallbashModes=("theme" "auto" "dark" "light")

# Variables que antes estaban en globalcontrol.sh
enableWallDcol=0               # Modo inicial (puede ser 0, 1, 2, 3)
rofiScale=10                   # Tamaño de fuente de rofi
hypr_border=1                  # Borde base

# Función para actualizar config (simulación sin archivo externo)
set_conf() {
    enableWallDcol=$2
}

# Rofi selector
rofi_wallbash() {
    r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"
    elem_border=$(( hypr_border * 4 ))
    r_override="window{border-radius:${elem_border}px;} element{border-radius:${elem_border}px;}"
    rofiSel=$(printf "%s\n" "${wallbashModes[@]}" | rofi -dmenu -theme-str "${r_scale}" -theme-str "${r_override}" -config "${rofiConf}" -select "${wallbashModes[${enableWallDcol}]}")

    if [ -n "${rofiSel}" ]; then
        for idx in "${!wallbashModes[@]}"; do
            if [ "${wallbashModes[$idx]}" = "${rofiSel}" ]; then
                setMode=$idx
                break
            fi
        done
    else
        exit 0
    fi
}

# Cambiar al siguiente o anterior modo
step_wallbash() {
    for i in "${!wallbashModes[@]}"; do
        if [ "${enableWallDcol}" = "${i}" ]; then
            if [ "${1}" = "n" ]; then
                setMode=$(( (i + 1) % ${#wallbashModes[@]} ))
            elif [ "${1}" = "p" ]; then
                setMode=$(( i - 1 ))
            fi
            break
        fi
    done
}

# Interpretar argumento
case "${1}" in
    m|-m|--menu) rofi_wallbash ;;
    n|-n|--next) step_wallbash n ;;
    p|-p|--prev) step_wallbash p ;;
    *)           step_wallbash n ;;
esac

# Validar resultado
[ -z "${setMode}" ] && setMode=0
[ "${setMode}" -lt 0 ] && setMode=$((${#wallbashModes[@]} - 1))

# Actualizar modo
set_conf "enableWallDcol" "${setMode}"

# Ejecutar cambio de tema
"${scrDir}/themeswitch.sh"

# Notificación
notify-send -a "t1" -i "$HOME/.config/dunst/icons/hyprdots.png" " ${wallbashModes[setMode]} mode"
