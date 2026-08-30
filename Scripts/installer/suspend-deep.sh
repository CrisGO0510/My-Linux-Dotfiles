#!/bin/bash
# Modo de suspension: S3 (deep) en vez de s2idle.
#
# El kernel elige s2idle por defecto aunque el firmware soporte S3
# (este equipo declara "ACPI: PM: (supports S0 S3 S4 S5)"). s2idle deja la
# maquina en un letargo superficial que drena ~2 W; S3 corta la alimentacion
# de casi todo y baja a ~0.5 W.
#
# Se hace con tmpfiles.d en vez de mem_sleep_default=deep en el cmdline: el
# efecto es el mismo, pero no hay que regenerar grub.cfg y revertirlo es
# borrar un archivo.

set -e

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

function info  { echo -e "${GREEN}[INFO]${RESET} $1"; }
function warn  { echo -e "${YELLOW}[WARN]${RESET} $1"; }
function error { echo -e "${RED}[ERROR]${RESET} $1"; }

MEM_SLEEP_PATH="/sys/power/mem_sleep"
TARGET_MODE="deep"
TMPFILES_CONF="/etc/tmpfiles.d/mem-sleep-deep.conf"

if [[ $EUID -eq 0 ]]; then
    error "No ejecutes este script como root. Pedira sudo cuando lo necesite."
    exit 1
fi

if [[ ! -w $MEM_SLEEP_PATH && ! -r $MEM_SLEEP_PATH ]]; then
    error "$MEM_SLEEP_PATH no existe: el kernel no expone modos de suspension."
    exit 1
fi

if ! grep -qw "$TARGET_MODE" "$MEM_SLEEP_PATH"; then
    error "El firmware no ofrece '$TARGET_MODE'. Modos disponibles: $(cat "$MEM_SLEEP_PATH")"
    error "Puede que S3 este desactivado en la BIOS del equipo."
    exit 1
fi

info "Escribiendo $TMPFILES_CONF"
sudo tee "$TMPFILES_CONF" >/dev/null <<EOF
# Gestionado por dotfiles (Scripts/installer/suspend-deep.sh).
# Fuerza S3 en cada arranque: mucho menos consumo en reposo que s2idle.
w $MEM_SLEEP_PATH - - - - $TARGET_MODE
EOF

info "Aplicando sin reiniciar"
sudo systemd-tmpfiles --create "$TMPFILES_CONF"

active=$(sed -n 's/.*\[\(.*\)\].*/\1/p' "$MEM_SLEEP_PATH")
if [[ "$active" == "$TARGET_MODE" ]]; then
    info "Modo de suspension activo: $active"
else
    warn "El modo activo sigue siendo '$active'. Revisa $TMPFILES_CONF."
    exit 1
fi

cat <<EOF

Para confirmar que S3 se usa de verdad, suspende el equipo y al volver:

  journalctl -k -b | grep "PM: suspend entry"

Debe decir "(deep)". Si dice "(s2idle)", el cambio no llego a aplicarse.

Si tras esto el equipo no despierta bien, revierte con:

  sudo rm $TMPFILES_CONF && sudo reboot

EOF
