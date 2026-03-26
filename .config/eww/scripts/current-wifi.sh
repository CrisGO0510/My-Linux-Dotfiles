#!/bin/bash

# Check ethernet first
eth_state=$(nmcli -t -f TYPE,STATE,DEVICE dev | grep '^ethernet:connected')

if [[ -n "$eth_state" ]]; then
    iface=$(echo "$eth_state" | cut -d: -f3)
    echo "{\"icon\": \"󰈀\", \"ssid\": \"Ethernet\", \"strength\": 100}"
    exit 0
fi

# Then check wifi
wifi_info=$(nmcli -t -f active,ssid,signal dev wifi 2>/dev/null | grep '^yes')

if [[ -z "$wifi_info" ]]; then
    echo '{"icon": "󰤭", "ssid": "Disconnected", "strength": 0}'
    exit 0
fi

ssid=$(echo "$wifi_info" | cut -d: -f2)
signal=$(echo "$wifi_info" | cut -d: -f3)

echo "{\"icon\": \"󰤨\", \"ssid\": \"${ssid^^}\", \"strength\": $signal}"
