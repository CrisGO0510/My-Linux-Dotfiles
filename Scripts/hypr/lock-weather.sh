#!/usr/bin/env bash
# Clima para hyprlock. Consulta wttr.in y cachea el resultado unos minutos
# para no golpear la red en cada refresco de las labels del lock.
# Uso: lock-weather.sh {icon|temp|cond}
#   icon -> glifo Nerd Font (nf-weather-*) segun la condicion
#   temp -> temperatura (ej. +25°C)
#   cond -> descripcion (ej. Light rain shower)

cache="/tmp/hypr-lock-weather"
max_age=900   # 15 minutos

fetch() {
    # %t = temperatura, %C = condicion en texto
    curl -s --max-time 8 'wttr.in/?format=%t|%C' 2>/dev/null
}

# Refresca el cache si no existe o esta viejo.
if [ ! -f "$cache" ] || [ "$(( $(date +%s) - $(stat -c %Y "$cache") ))" -gt "$max_age" ]; then
    data="$(fetch)"
    [ -n "$data" ] && printf '%s' "$data" >"$cache"
fi

data="$(cat "$cache" 2>/dev/null)"
temp="${data%%|*}"
cond="${data#*|}"

# Codepoint Nerd Font (nf-weather-*) segun palabras clave de la condicion.
hex=e30d   # por defecto: sol (day_sunny)
case "${cond,,}" in
    *thunder*|*storm*)               hex=e31d ;;  # tormenta
    *snow*|*sleet*|*blizzard*|*ice*) hex=e31a ;;  # nieve
    *rain*|*drizzle*|*shower*)       hex=e318 ;;  # lluvia
    *fog*|*mist*|*haze*)             hex=e313 ;;  # niebla
    *overcast*|*cloud*)              hex=e312 ;;  # nublado
    *clear*|*sunny*)                 hex=e30d ;;  # despejado
esac
icon="$(printf "\\u${hex}")"

case "$1" in
    icon) printf '%s' "$icon" ;;
    temp) printf '%s' "${temp:-N/A}" ;;
    cond) printf '%s' "${cond:-Sin datos}" ;;
    line) printf '%s\t%s\t%s' "$icon" "${temp:-N/A}" "${cond:-Sin datos}" ;;  # campos TAB-separados (para QML)
    *)    printf '%s  %s  %s' "$icon" "${temp:-N/A}" "${cond:-Sin datos}" ;;
esac
