#!/usr/bin/env sh

# Chequear si jq está instalado
if ! command -v jq &> /dev/null; then
    echo "ERROR: jq no está instalado. Instalalo con: sudo pacman -S jq"
    exit 1
fi

# Si wlogout está corriendo, matarlo
if pgrep -x "wlogout" > /dev/null; then
    pkill -x "wlogout"
    exit 0
fi

# Definir variables
confDir="${XDG_CONFIG_HOME:-$HOME/.config}"
[ -z "${1}" ] && wlogoutStyle="1" || wlogoutStyle="${1}"

wLayout="${confDir}/wlogout/layout_${wlogoutStyle}"
wlTmplt="${confDir}/wlogout/style_${wlogoutStyle}.css"

if [ ! -f "${wLayout}" ] || [ ! -f "${wlTmplt}" ]; then
    echo "ERROR: Config ${wlogoutStyle} not found..."
    exit 1
fi

# Detectar resolución y escala
x_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
y_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')
hypr_scale=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .scale' | sed 's/\.//')

[ -z "$hypr_scale" ] && echo "ERROR: No se pudo obtener hypr_scale" && exit 1

# Calcular márgenes y radios
case "${wlogoutStyle}" in
    1)  wlColms=6
        mgn=$(( y_mon * 28 / hypr_scale ))
        hvr=$(( y_mon * 23 / hypr_scale )) ;;
    2)  wlColms=2
        x_mgn=$(( x_mon * 35 / hypr_scale ))
        y_mgn=$(( y_mon * 25 / hypr_scale ))
        x_hvr=$(( x_mon * 32 / hypr_scale ))
        y_hvr=$(( y_mon * 20 / hypr_scale )) ;;
esac

fntSize=$(( y_mon * 2 / 100 ))
BtnCol="white"
active_rad=20
button_rad=32

# Exportar variables para el CSS
export fntSize BtnCol active_rad button_rad mgn hvr x_mgn y_mgn x_hvr y_hvr

# Renderizar el CSS
wlStyle="$(envsubst < $wlTmplt)"

# Lanzar wlogout
wlogout -b "${wlColms}" -c 0 -r 0 -m 0 --layout "${wLayout}" --css <(echo "${wlStyle}") --protocol layer-shell
