#!/usr/bin/env bash
#
# fan-control-setup.sh — habilita el control de los ventiladores de la placa
# (Gigabyte B450M DS3H WIFI, super I/O ITE) y saca el modulo amdgpu que se
# carga a la fuerza sin que haya ninguna GPU AMD en la maquina.
#
# El super I/O no lo maneja ningun driver del kernel mainline: hace falta
# it87-dkms (ya instalado). Lo que falta es cargarlo, y para eso puede que
# haya que aflojar el arbitraje de recursos de ACPI.
#
# El script prueba primero SIN tocar la linea de kernel. Solo si el modulo
# choca contra ACPI agrega `acpi_enforce_resources=lax`, porque relajar eso
# es efectivo pero deja que el kernel pise regiones que ACPI reclama: no es
# algo que convenga poner "por las dudas".
#
# Uso:
#   ./fan-control-setup.sh [--dry-run]
#
# Idempotente. Respalda todo lo que toca como <archivo>.bak-<fecha>.

set -euo pipefail

DRY_RUN=0
case "${1:-}" in
    --dry-run) DRY_RUN=1 ;;
    "")        ;;
    *)         printf 'Uso: %s [--dry-run]\n' "${0##*/}" >&2; exit 2 ;;
esac

readonly HWMON_LOAD_CONF="/etc/modules-load.d/hwmon.conf"
readonly IT87_LOAD_CONF="/etc/modules-load.d/it87.conf"
readonly IT87_MODPROBE_CONF="/etc/modprobe.d/it87.conf"
readonly BOOT_ENTRIES_DIR="/boot/loader/entries"
readonly ACPI_PARAM="acpi_enforce_resources=lax"
readonly STAMP="$(date +%Y%m%d-%H%M%S)"

# IT8686E es el super I/O de la B450M DS3H WIFI; el resto son los que suele
# traer el resto de la gama por si la deteccion automatica no acierta.
readonly FORCE_IDS=(0x8686 0x8628 0x8792)

NEED_REBOOT=0
ACPI_PARAM_ADDED=0

readonly C_OK=$'\e[1;32m' C_STEP=$'\e[1;34m' C_WARN=$'\e[1;33m'
readonly C_ERR=$'\e[1;31m' C_DIM=$'\e[2m' C_OFF=$'\e[0m'

step() { printf '\n%s:: %s%s\n' "$C_STEP" "$*" "$C_OFF"; }
info() { printf '%s  ok%s  %s\n' "$C_OK" "$C_OFF" "$*"; }
skip() { printf '%s  --  %s%s\n' "$C_DIM" "$*" "$C_OFF"; }
warn() { printf '%s  !!%s  %s\n' "$C_WARN" "$C_OFF" "$*" >&2; }
die()  { printf '\n%s  xx%s  %s\n\n' "$C_ERR" "$C_OFF" "$*" >&2; exit 1; }

root() {
    if (( DRY_RUN )); then
        printf '%s  [dry] sudo %s%s\n' "$C_DIM" "$*" "$C_OFF"
        return 0
    fi
    sudo "$@"
}

root_write() {
    local path="$1"
    if (( DRY_RUN )); then
        printf '%s  [dry] escribiria %s:%s\n' "$C_DIM" "$path" "$C_OFF"
        sed "s/^/${C_DIM}        /; s/\$/${C_OFF}/"
        return 0
    fi
    sudo tee "$path" >/dev/null
}

backup() {
    local file="$1"
    [[ -f "$file" ]] || return 0
    root cp -a "$file" "${file}.bak-${STAMP}"
    skip "respaldo: ${file##*/}.bak-${STAMP}"
}

# Nombres de los hwmon presentes, uno por linea.
hwmon_names() {
    local d
    for d in /sys/class/hwmon/hwmon*; do
        [[ -r "$d/name" ]] && cat "$d/name"
    done
}


# █▀█ █▀█ █▀▀ █▀▀ █░░ █ █▀▀ █░█ ▀█▀
# █▀▀ █▀▄ ██▄ █▀░ █▄▄ █ █▄█ █▀█ ░█░

preflight() {
    step "Verificaciones previas"

    (( EUID != 0 )) || die "No lo corras con sudo; pide root donde hace falta."

    modinfo it87 &>/dev/null \
        || die "No hay modulo it87 para el kernel $(uname -r). Instala it87-dkms-git:
          yay -S it87-dkms-git"
    info "it87 disponible para $(uname -r)"

    if (( ! DRY_RUN )); then
        sudo -v || die "Sin sudo no puedo seguir."
    fi
}


# ▄▀█ █▀▄▀█ █▀▄ █▀▀ █▀█ █░█
# █▀█ █░▀░█ █▄▀ █▄█ █▀▀ █▄█

limpiar_amdgpu() {
    step "amdgpu — modulo cargado sin hardware que lo use"

    # Se filtra por vendor+clase del bus PCI (1002 = AMD/ATI, 0300 = VGA) y no
    # por el texto: un grep -i de "ATI" matchea "NVIDIA CorporATIon".
    local vga_amd
    vga_amd="$(lspci -d '1002::0300' 2>/dev/null | wc -l)"
    if (( vga_amd > 0 )); then
        skip "hay una GPU AMD presente, no toco nada"
        return 0
    fi

    if [[ ! -f "$HWMON_LOAD_CONF" ]] || ! grep -qx 'amdgpu' "$HWMON_LOAD_CONF"; then
        skip "amdgpu no se fuerza desde ${HWMON_LOAD_CONF##*/}"
        return 0
    fi

    info "sin GPU AMD en el bus; ${HWMON_LOAD_CONF##*/} lo carga a la fuerza"
    backup "$HWMON_LOAD_CONF"
    if (( DRY_RUN )); then
        printf '%s  [dry] sacaria la linea «amdgpu» de %s%s\n' "$C_DIM" "$HWMON_LOAD_CONF" "$C_OFF"
    else
        sudo sed -i '/^amdgpu$/d' "$HWMON_LOAD_CONF"
        info "linea 'amdgpu' removida"
    fi
    NEED_REBOOT=1
}


# █ ▀█▀ ▄▀█ ▀▀█
# █ ░█░ █▄█ █▄▄

# Combinaciones a probar, de la menos invasiva a la mas. ignore_resource_conflict
# esta acotado a este driver, asi que se prefiere antes que acpi_enforce_resources,
# que afloja el arbitraje de ACPI para todo el kernel.
candidatos_it87() {
    printf '%s\n' "" "ignore_resource_conflict=1"
    local id
    for id in "${FORCE_IDS[@]}"; do
        printf '%s\n' "force_id=$id" "force_id=$id ignore_resource_conflict=1"
    done
}

# Carga it87 con los argumentos dados y responde si aparecio un hwmon it8xx.
probar_it87() {
    local args="$1"
    sudo modprobe -r it87 2>/dev/null || true
    # shellcheck disable=SC2086  -- $args se quiere partir en palabras
    sudo modprobe it87 $args 2>/dev/null || return 1
    hwmon_names | grep -q '^it8'
}

cargar_it87() {
    step "it87 — sensores y PWM del super I/O"

    if hwmon_names | grep -q '^it8'; then
        info "ya hay un hwmon it8xx activo: $(hwmon_names | grep '^it8' | tr '\n' ' ')"
        persistir_it87
        return 0
    fi

    if (( DRY_RUN )); then
        printf '%s  [dry] probaria, en orden:%s\n' "$C_DIM" "$C_OFF"
        candidatos_it87 | sed "s|^|${C_DIM}          modprobe it87 |; s|\$|${C_OFF}|"
        return 0
    fi

    # El modprobe.d que gestiona este script se aparta antes de probar: si no,
    # sus opciones se aplicarian por debajo y terminariamos persistiendo una
    # combinacion incompleta, creyendo que funciono sola.
    if [[ -f "$IT87_MODPROBE_CONF" ]]; then
        backup "$IT87_MODPROBE_CONF"
        sudo rm -f "$IT87_MODPROBE_CONF"
    fi

    local args
    while IFS= read -r args; do
        if probar_it87 "$args"; then
            info "it87 cargado${args:+ con: $args}"
            persistir_it87 "$args"
            return 0
        fi
    done < <(candidatos_it87)

    sudo modprobe -r it87 2>/dev/null || true
    warn "it87 no carga con ninguna combinacion de opciones del modulo."
    local motivo
    motivo="$(journalctl -b --no-pager 2>/dev/null | grep -iE 'it87|resource conflict' | tail -4)"
    [[ -n "$motivo" ]] && printf '%s%s%s\n' "$C_DIM" "$motivo" "$C_OFF"

    agregar_param_acpi
}

# Persiste la carga al arranque. `args` DEBE ser el juego completo de opciones
# que funciono: guardar solo una parte es como fallaba la version anterior.
persistir_it87() {
    local args="${1:-}"

    if [[ -f "$IT87_LOAD_CONF" ]] && grep -qx 'it87' "$IT87_LOAD_CONF"; then
        skip "${IT87_LOAD_CONF##*/} ya existe"
    else
        printf 'it87\n' | root_write "$IT87_LOAD_CONF"
        info "creado $IT87_LOAD_CONF"
    fi

    [[ -n "$args" ]] || return 0

    printf 'options it87 %s\n' "$args" | root_write "$IT87_MODPROBE_CONF"
    info "${IT87_MODPROBE_CONF##*/}: options it87 $args"
}


# ▄▀█ █▀▀ █▀█ █
# █▀█ █▄▄ █▀▀ █

agregar_param_acpi() {
    step "acpi_enforce_resources=lax en la linea de kernel"

    if grep -q "$ACPI_PARAM" /proc/cmdline; then
        warn "el parametro YA esta activo y aun asi it87 no carga."
        warn "Revisa que el chip sea realmente un ITE: sudo sensors-detect"
        return 0
    fi

    local entry cambiadas=0
    shopt -s nullglob
    for entry in "$BOOT_ENTRIES_DIR"/*.conf; do
        grep -q "^options" "$entry" || continue
        if grep -q "$ACPI_PARAM" "$entry"; then
            skip "${entry##*/} ya lo tiene"
            continue
        fi
        backup "$entry"
        root sed -i "s|^options .*|& $ACPI_PARAM|" "$entry"
        info "${entry##*/} actualizada"
        cambiadas=1
    done
    shopt -u nullglob

    (( cambiadas )) || { warn "No encontre entradas de systemd-boot que tocar."; return 0; }

    # Se persiste igual: en el proximo arranque el modulo ya deberia entrar.
    persistir_it87
    ACPI_PARAM_ADDED=1
    NEED_REBOOT=1
}


# █▀▀ █ █▄░█ ▄▀█ █░░
# █▀░ █ █░▀█ █▀█ █▄▄

resumen() {
    step "Resumen"

    if hwmon_names | grep -q '^it8'; then
        info "PWM disponible ya mismo. Verifica con: sensors"
        printf '\n  Ahora si podes usar una curva de ventiladores:\n'
        printf '    sudo pacman -S coolercontrol && sudo systemctl enable --now coolercontrold\n'
        printf '    (o el clasico: sudo pwmconfig && sudo systemctl enable --now fancontrol)\n'
    elif (( ACPI_PARAM_ADDED )); then
        warn "Hace falta reiniciar para que tome acpi_enforce_resources=lax."
        printf '\n  Despues del reinicio:\n'
        printf '    sensors | grep -A20 it8      # deberian salir fan1..fan5 y pwm1..pwm5\n'
        printf '    Si no aparece nada, corre: sudo sensors-detect\n'
    else
        warn "it87 todavia no expone PWM. Volve a correr el script tras reiniciar."
    fi

    if (( NEED_REBOOT )); then
        printf '\n%s  Reinicia cuando puedas.%s\n' "$C_WARN" "$C_OFF"
    fi

    printf '\n  Lo unico que ningun script puede hacer por vos:\n'
    printf '    BIOS → Above 4G Decoding = Enabled\n'
    printf '    BIOS → Re-Size BAR Support = Enabled   (BAR1 hoy: 256 MiB de 12 GB)\n'
    printf '    BIOS → CSM = Disabled                  (requisito de ReBAR)\n'
}

main() {
    preflight
    limpiar_amdgpu
    cargar_it87
    resumen
}

main "$@"
