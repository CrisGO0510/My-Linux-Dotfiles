#!/bin/bash

update_ws() {
    local monitor=$1
    local workspaces=($(hyprctl workspaces -j | jq -r "[.[] | select(.monitorID == $monitor) | .id] | sort | .[]"))
    local current=$(hyprctl monitors -j | jq -r ".[] | select(.id == $monitor) | .activeWorkspace.id")

    output="(box :class \"ws\" :orientation \"h\" :spacing 5 :space-evenly \"false\""
    for ws in "${workspaces[@]}"; do
        if [[ "$ws" == "$current" ]]; then
            output+=" (eventbox :onclick \"hyprctl dispatch workspace $ws\" :cursor \"pointer\" :class \"visiting\" (label :text \"$ws\"))"
        else
            output+=" (eventbox :onclick \"hyprctl dispatch workspace $ws\" :cursor \"pointer\" :class \"free\" (label :text \"$ws\"))"
        fi
    done
    output+=")"
    echo "$output"
}

# --- Inicialización al arrancar ---
eww update workspaces-output-0="$(update_ws 0)"
eww update workspaces-output-1="$(update_ws 1)"

# --- Suscripción a eventos de Hyprland ---
while read -r line; do
    case $line in
        "workspace>>"*|"createworkspace>>"*|"destroyworkspace>>"*)
            eww update workspaces-output-0="$(update_ws 0)"
            eww update workspaces-output-1="$(update_ws 1)"
            ;;
    esac
done < <(
    socat -U - UNIX-CONNECT:"/run/user/1000/hypr/$(ls -td /run/user/1000/hypr/*/ | head -n1 | xargs basename)/.socket2.sock"
)
