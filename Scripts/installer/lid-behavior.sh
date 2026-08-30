#!/bin/bash
# Comportamiento del cierre de tapa.
#
# Por defecto systemd-logind suspende el equipo al cerrar la tapa
# (HandleLidSwitch=suspend). Aca lo desactivamos para que la laptop siga
# ejecutando todo con la tapa cerrada y siga accesible por SSH.
#
# La suspension manual no se toca: wlogout sigue llamando a `systemctl suspend`.
# El apagado del panel al cerrar lo hace Hyprland (ver keybindings.lua).

set -e

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

function info  { echo -e "${GREEN}[INFO]${RESET} $1"; }
function warn  { echo -e "${YELLOW}[WARN]${RESET} $1"; }
function error { echo -e "${RED}[ERROR]${RESET} $1"; }

LOGIND_DROPIN_DIR="/etc/systemd/logind.conf.d"
LOGIND_DROPIN="$LOGIND_DROPIN_DIR/10-lid.conf"

if [[ $EUID -eq 0 ]]; then
    error "No ejecutes este script como root. Pedira sudo cuando lo necesite."
    exit 1
fi

info "Escribiendo $LOGIND_DROPIN"
sudo mkdir -p "$LOGIND_DROPIN_DIR"
sudo tee "$LOGIND_DROPIN" >/dev/null <<'EOF'
# Gestionado por dotfiles (Scripts/installer/lid-behavior.sh).
# Cerrar la tapa no suspende: la sesion sigue viva y accesible por SSH.
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
EOF

# HUP recarga la config sin reiniciar el servicio: un `restart` de logind
# puede tumbar la sesion grafica en curso.
info "Recargando systemd-logind"
sudo systemctl kill -s HUP systemd-logind

if command -v busctl &>/dev/null; then
    actual=$(busctl get-property org.freedesktop.login1 /org/freedesktop/login1 \
        org.freedesktop.login1.Manager HandleLidSwitch 2>/dev/null || true)
    if [[ "$actual" == *ignore* ]]; then
        info "logind reporta HandleLidSwitch=ignore."
    else
        warn "logind aun reporta: ${actual:-desconocido}. Revisa $LOGIND_DROPIN."
    fi
fi

info "Listo. Cerrar la tapa ya no suspende el equipo."
