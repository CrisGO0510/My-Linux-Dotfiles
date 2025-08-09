#!/bin/bash

# Primer muestreo
PREV=($(grep '^cpu' /proc/stat | awk '{print $2,$3,$4,$5,$6,$7,$8}'))
sleep 0.5
CURR=($(grep '^cpu' /proc/stat | awk '{print $2,$3,$4,$5,$6,$7,$8}'))

CPU_COUNT=$(grep -c '^cpu' /proc/stat) # incluye la línea "cpu" total
USAGES=()

for ((i=0; i<$CPU_COUNT; i++)); do
    PREV_USER=${PREV[$((i*7))]}
    PREV_NICE=${PREV[$((i*7+1))]}
    PREV_SYSTEM=${PREV[$((i*7+2))]}
    PREV_IDLE=${PREV[$((i*7+3))]}
    PREV_IOWAIT=${PREV[$((i*7+4))]}
    PREV_IRQ=${PREV[$((i*7+5))]}
    PREV_SOFTIRQ=${PREV[$((i*7+6))]}

    CURR_USER=${CURR[$((i*7))]}
    CURR_NICE=${CURR[$((i*7+1))]}
    CURR_SYSTEM=${CURR[$((i*7+2))]}
    CURR_IDLE=${CURR[$((i*7+3))]}
    CURR_IOWAIT=${CURR[$((i*7+4))]}
    CURR_IRQ=${CURR[$((i*7+5))]}
    CURR_SOFTIRQ=${CURR[$((i*7+6))]}

    PREV_IDLE_TOTAL=$((PREV_IDLE + PREV_IOWAIT))
    CURR_IDLE_TOTAL=$((CURR_IDLE + CURR_IOWAIT))

    PREV_TOTAL=$((PREV_USER + PREV_NICE + PREV_SYSTEM + PREV_IDLE + PREV_IOWAIT + PREV_IRQ + PREV_SOFTIRQ))
    CURR_TOTAL=$((CURR_USER + CURR_NICE + CURR_SYSTEM + CURR_IDLE + CURR_IOWAIT + CURR_IRQ + CURR_SOFTIRQ))

    DIFF_TOTAL=$((CURR_TOTAL - PREV_TOTAL))
    DIFF_IDLE=$((CURR_IDLE_TOTAL - PREV_IDLE_TOTAL))

    USAGE=$(( (100 * (DIFF_TOTAL - DIFF_IDLE)) / DIFF_TOTAL ))
    USAGES+=($USAGE)
done

# El primero (USAGES[0]) es el uso total, el resto son núcleos
TOTAL=${USAGES[0]}
CORES_JSON=$(printf "%s," "${USAGES[@]:1}")
CORES_JSON="[${CORES_JSON%,}]"

# echo "{\"total\": $TOTAL, \"cores\": $CORES_JSON}"
echo $CORES_JSON
