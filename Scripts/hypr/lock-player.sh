#!/usr/bin/env bash
# Now-playing para hyprlock via playerctl.
# Uso: lock-player.sh {title|artist|status}
#   title  -> titulo de lo que suena (o mensaje si no hay nada)
#   artist -> artista / autor (vacio si no aplica)
#   status -> glifo Nerd Font de play/pause

# Toma el primer reproductor activo (playing) o, si no hay, cualquiera.
player="$(playerctl -l 2>/dev/null | head -1)"
status="$(playerctl status 2>/dev/null)"

title="$(playerctl metadata --format '{{title}}' 2>/dev/null)"
artist="$(playerctl metadata --format '{{artist}}' 2>/dev/null)"

# Glifos Nerd Font: play (nf-md-play U+F040A) / pause (nf-md-pause U+F03E4).
# Estan fuera del BMP, asi que se emiten con \U (8 digitos hex).
hex_play=000f040a
hex_pause=000f03e4

case "$1" in
    title)
        if [ -n "$title" ]; then
            printf '%s' "$title"
        else
            printf 'Nada reproduciendose'
        fi
        ;;
    artist)
        printf '%s' "$artist"
        ;;
    status)
        if [ "$status" = "Playing" ]; then
            printf "\\U${hex_play}"
        else
            printf "\\U${hex_pause}"
        fi
        ;;
esac
