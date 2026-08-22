#!/usr/bin/env sh

# Cierra la sesion de Hyprland.
#
# `hyprctl dispatch` cambia de sintaxis segun el gestor de config: con hyprlang
# espera el nombre del dispatcher ("exit"), con Lua espera una expresion
# ("hl.dsp.exit()"). hyprctl siempre devuelve 0, asi que se distingue por la
# salida. Cuando ya no quede ninguna maquina en hyprlang, esto se reduce a la
# rama de Lua.

if [ "$(hyprctl dispatch 'hl.dsp.exit()')" = "ok" ]; then
    exit 0
fi

hyprctl dispatch exit
