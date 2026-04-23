#!/bin/bash

update_ws() {
    local monitor=$1
    local ws_data
    ws_data=$(hyprctl workspaces -j | jq -c "[.[] | select(.monitorID == $monitor) | {id: .id, windows: .windows}] | sort_by(.id)")
    local current
    current=$(hyprctl monitors -j | jq -r ".[] | select(.id == $monitor) | .activeWorkspace.id")

    output="(box :class \"ws\" :orientation \"h\" :spacing 5 :space-evenly \"false\""

    while IFS= read -r ws_json; do
        local id windows class
        id=$(echo "$ws_json" | jq -r '.id')
        windows=$(echo "$ws_json" | jq -r '.windows')
        if [[ "$id" == "$current" ]]; then
            class="ws-num active"
        elif [[ "$windows" -gt 0 ]]; then
            class="ws-num has-windows"
        else
            class="ws-num empty"
        fi
        output+=" (eventbox :onclick \"hyprctl dispatch workspace $id\" :cursor \"pointer\" :class \"${class}\" (label :text \"$id\"))"
    done < <(echo "$ws_data" | jq -c '.[]')

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
