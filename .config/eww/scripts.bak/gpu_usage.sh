#!/bin/bash

# Script para obtener el porcentaje de uso de GPU AMD via radeontop
# Retorna solo el valor numérico del porcentaje de uso

gpu_usage=$(radeontop -d - -l 1 2>/dev/null | \
           awk '/bus.*gpu/ {gsub(/[,:%]/, " "); print $4}')

# Validar que el resultado sea un número válido
if [[ "$gpu_usage" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    # Redondear a número entero
    printf "%.0f" "$gpu_usage"
else
    # Fallback si no se puede leer la GPU
    echo "0"
fi