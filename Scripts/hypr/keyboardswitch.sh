#!/usr/bin/env sh

hyprctl switchxkblayout all next

layMain=$(hyprctl -j devices | jq '.keyboards' | jq '.[] | select (.main == true)' | awk -F '"' '{if ($2=="active_keymap") print $4}')
notify-send -a "t1" -r 91190 -t 800 -i "~/.config/dunst/icons/keyboard.svg" "${layMain}"

