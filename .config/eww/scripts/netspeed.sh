#!/bin/bash
IFACE="enp12s0"
RX1=$(cat /sys/class/net/$IFACE/statistics/rx_bytes 2>/dev/null || echo 0)
TX1=$(cat /sys/class/net/$IFACE/statistics/tx_bytes 2>/dev/null || echo 0)
sleep 1
RX2=$(cat /sys/class/net/$IFACE/statistics/rx_bytes 2>/dev/null || echo 0)
TX2=$(cat /sys/class/net/$IFACE/statistics/tx_bytes 2>/dev/null || echo 0)

DOWN=$(( RX2 - RX1 ))
UP=$(( TX2 - TX1 ))

DOWN_STR=$(awk "BEGIN{printf \"%.1f\", $DOWN/1048576}")
UP_STR=$(awk "BEGIN{printf \"%.1f\", $UP/1048576}")

echo "{\"up\":\"${UP_STR} MB/s\",\"down\":\"${DOWN_STR} MB/s\"}"
