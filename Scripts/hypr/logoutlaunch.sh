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
# La escala se normaliza a decimas enteras (1 -> 10, 1.5 -> 15). No sirve
# borrar el punto con sed: Hyprland devuelve "1", no "1.0", en escalas exactas.
hypr_scale=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .scale * 10 | round')

[ -z "$hypr_scale" ] && echo "ERROR: No se pudo obtener hypr_scale" && exit 1

# hyprctl reporta pixeles fisicos, pero el CSS de wlogout trabaja en pixeles
# logicos (ya escalados). SCALE_UNIT es el divisor de las decimas de hypr_scale.
SCALE_UNIT=10
x_log=$(( x_mon * SCALE_UNIT / hypr_scale ))
y_log=$(( y_mon * SCALE_UNIT / hypr_scale ))

# Los margenes se expresan como porcentaje del lado correspondiente: dejan los
# botones centrados en una banda, y el margen de hover es algo menor para que
# el boton "crezca" al pasar por encima.
PCT_MARGIN_1=28
PCT_HOVER_1=23
PCT_MARGIN_X_2=35
PCT_MARGIN_Y_2=25
PCT_HOVER_X_2=32
PCT_HOVER_Y_2=20
PCT_FONT=2

case "${wlogoutStyle}" in
    1)  wlColms=5
        mgn=$(( y_log * PCT_MARGIN_1 / 100 ))
        hvr=$(( y_log * PCT_HOVER_1 / 100 )) ;;
    2)  wlColms=2
        x_mgn=$(( x_log * PCT_MARGIN_X_2 / 100 ))
        y_mgn=$(( y_log * PCT_MARGIN_Y_2 / 100 ))
        x_hvr=$(( x_log * PCT_HOVER_X_2 / 100 ))
        y_hvr=$(( y_log * PCT_HOVER_Y_2 / 100 )) ;;
esac

fntSize=$(( y_log * PCT_FONT / 100 ))
BtnCol="white"
active_rad=20
button_rad=32

# Exportar variables para el CSS
export fntSize BtnCol active_rad button_rad mgn hvr x_mgn y_mgn x_hvr y_hvr

# Renderizar el CSS
wlStyle="$(envsubst < $wlTmplt)"

# Lanzar wlogout
wlogout -b "${wlColms}" -c 0 -r 0 -m 0 --layout "${wLayout}" --css <(echo "${wlStyle}") --protocol layer-shell
