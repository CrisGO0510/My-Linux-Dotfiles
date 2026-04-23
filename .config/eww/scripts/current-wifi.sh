#!/bin/bash

# Check ethernet first
eth_state=$(nmcli -t -f TYPE,STATE,DEVICE dev | grep '^ethernet:connected')

if [[ -n "$eth_state" ]]; then
    echo "{\"icon\": \"󰈀\", \"ssid\": \"Ethernet\", \"strength\": 100, \"band\": \"wired\", \"security\": \"--\"}"
    exit 0
fi

# Then check wifi (active connection only)
wifi_info=$(nmcli -t -f active,ssid,signal,freq,security dev wifi 2>/dev/null | grep '^yes' | head -n1)

if [[ -z "$wifi_info" ]]; then
    echo '{"icon": "󰤭", "ssid": "Disconnected", "strength": 0, "band": "--", "security": "--"}'
    exit 0
fi

ssid=$(echo "$wifi_info" | cut -d: -f2)
signal=$(echo "$wifi_info" | cut -d: -f3)
freq=$(echo "$wifi_info" | cut -d: -f4)
security=$(echo "$wifi_info" | cut -d: -f5)

# Derive band from frequency (MHz)
if [[ -n "$freq" && "$freq" -ge 4900 ]]; then
    band="5GHz"
elif [[ -n "$freq" && "$freq" -ge 2000 ]]; then
    band="2.4GHz"
else
    band="--"
fi

# Normalize security: empty/blank means open
[[ -z "$security" ]] && security="Open"

echo "{\"icon\": \"󰤨\", \"ssid\": \"${ssid^^}\", \"strength\": $signal, \"band\": \"$band\", \"security\": \"$security\"}"
