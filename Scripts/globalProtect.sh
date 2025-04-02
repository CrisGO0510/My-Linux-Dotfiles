#!/bin/zsh

# Obtener la ruta del script
SCRIPT_DIR=$(dirname "$0")

# Cargar variables desde el .env si existe
ENV_FILE="$SCRIPT_DIR/.env"
if [ -f "$ENV_FILE" ]; then
    export $(grep -v '^#' "$ENV_FILE" | xargs)
else
    echo "Error: No se encontró el archivo .env en $SCRIPT_DIR"
    exit 1
fi

# Conectar a VPN
echo "$PASS" | sudo openconnect --protocol=gp --user="$USER" --passwd-on-stdin intra.utp.edu.co
