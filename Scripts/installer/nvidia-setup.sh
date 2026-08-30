#!/usr/bin/env bash
#
# nvidia-setup.sh — pasos 2, 3 y 4 de la migracion a los drivers propietarios
# de NVIDIA en Arch + Hyprland (RTX 4070, kernel `linux`).
#
#   2. Modulos nvidia dentro del initramfs y el hook `kms` fuera.
#   3. Preservacion de la VRAM al suspender/hibernar + servicios asociados.
#   4. Variables de entorno de NVIDIA en hyprland.lua.
#
# El paso 1 (instalar nvidia-open) queda deliberadamente fuera: es la parte que
# conviene mirar mientras pasa, y sin ella los pasos 2 y 3 no tienen sentido.
# El script se niega a correr si el driver todavia no esta.
#
# Uso:
#   ./nvidia-setup.sh [--dry-run]
#
# Es idempotente: correrlo dos veces no duplica nada. Cada archivo que toca
# queda respaldado como <archivo>.bak-<fecha>.

set -euo pipefail

DRY_RUN=0
case "${1:-}" in
    --dry-run) DRY_RUN=1 ;;
    "")        ;;
    *)         printf 'Uso: %s [--dry-run]\n' "${0##*/}" >&2; exit 2 ;;
esac

readonly MKINITCPIO_CONF="/etc/mkinitcpio.conf"
readonly MODPROBE_CONF="/etc/modprobe.d/nvidia-power-management.conf"
readonly HYPR_CONF="${HOME}/dotfiles/.config/hypr/hyprland.lua"
readonly STAMP="$(date +%Y%m%d-%H%M%S)"
readonly NVIDIA_MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
readonly SUSPEND_SERVICES=(nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service)

# El initramfs se regenera una sola vez al final: tanto los modulos como
# /etc/modprobe.d entran en el, asi que rebuildear en cada paso seria tiempo
# tirado.
NEED_INITRAMFS=0

# Los temporales se limpian en un unico trap EXIT: un trap RETURN dentro de una
# funcion se hereda a las siguientes y revienta contra `set -u`.
TMP_FILES=()
cleanup() { (( ${#TMP_FILES[@]} )) && rm -f "${TMP_FILES[@]}"; return 0; }
trap cleanup EXIT

mktemp_tracked() {
    local f; f="$(mktemp)"; TMP_FILES+=("$f"); printf '%s\n' "$f"
}


# █░░ █▀█ █▀▀
# █▄▄ █▄█ █▄█

readonly C_OK=$'\e[1;32m' C_STEP=$'\e[1;34m' C_WARN=$'\e[1;33m'
readonly C_ERR=$'\e[1;31m' C_DIM=$'\e[2m' C_OFF=$'\e[0m'

step() { printf '\n%s:: %s%s\n' "$C_STEP" "$*" "$C_OFF"; }
info() { printf '%s  ok%s  %s\n' "$C_OK" "$C_OFF" "$*"; }
skip() { printf '%s  --  %s%s\n' "$C_DIM" "$*" "$C_OFF"; }
warn() { printf '%s  !!%s  %s\n' "$C_WARN" "$C_OFF" "$*" >&2; }
die()  { printf '\n%s  xx%s  %s\n\n' "$C_ERR" "$C_OFF" "$*" >&2; exit 1; }

# Ejecuta como root, o lo anuncia si es un ensayo.
root() {
    if (( DRY_RUN )); then
        printf '%s  [dry] sudo %s%s\n' "$C_DIM" "$*" "$C_OFF"
        return 0
    fi
    sudo "$@"
}

# Escribe stdin en un archivo de root.
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
    local file="$1" as_root="${2:-root}"
    [[ -f "$file" ]] || return 0
    if [[ "$as_root" == root ]]; then
        root cp -a "$file" "${file}.bak-${STAMP}"
    elif (( ! DRY_RUN )); then
        cp -a "$file" "${file}.bak-${STAMP}"
    fi
    skip "respaldo: ${file##*/}.bak-${STAMP}"
}


# █▀█ █▀█ █▀▀ █▀▀ █░░ █ █▀▀ █░█ ▀█▀
# █▀▀ █▀▄ ██▄ █▀░ █▄▄ █ █▄█ █▀█ ░█░

preflight() {
    step "Verificaciones previas"

    [[ -f /etc/arch-release ]] || die "Este script asume Arch Linux."
    (( EUID != 0 )) || die "No lo corras con sudo. Pide root solo donde hace falta."

    pacman -Qq nvidia-utils &>/dev/null || die \
"nvidia-utils no esta instalado, asi que los pasos 2 y 3 no tienen que hacer.
        Corre primero el paso 1:

          sudo pacman -Rns xf86-video-nouveau vulkan-nouveau
          sudo pacman -S nvidia-open nvidia-utils lib32-nvidia-utils \\
                         nvidia-settings libva-nvidia-driver"

    local pkg found=""
    for pkg in nvidia-open nvidia-open-dkms nvidia-open-lts nvidia nvidia-dkms; do
        if pacman -Qq "$pkg" &>/dev/null; then found="$pkg"; break; fi
    done
    [[ -n "$found" ]] || die "Tenes nvidia-utils pero ningun modulo de kernel (nvidia-open). Instalalo."
    info "modulo de kernel: $found"

    modinfo nvidia &>/dev/null \
        || warn "modinfo no encuentra 'nvidia' para el kernel $(uname -r). Si venis de instalar recien, seguí; si no, revisa el DKMS."

    for pkg in xf86-video-nouveau vulkan-nouveau; do
        pacman -Qq "$pkg" &>/dev/null \
            && warn "$pkg sigue instalado; sacalo o le va a competir a NVIDIA por el ICD de Vulkan."
    done

    [[ -f "$MKINITCPIO_CONF" ]] || die "No existe $MKINITCPIO_CONF"
    [[ -f "$HYPR_CONF" ]]       || die "No existe $HYPR_CONF"

    if (( ! DRY_RUN )); then
        info "pidiendo sudo por adelantado"
        sudo -v || die "Sin sudo no puedo seguir."
    fi
}


# █▀█ ▄▀█ █▀ █▀█   ▀█
# █▀▀ █▀█ ▄█ █▄█   █▄

step2_initramfs() {
    step "Paso 2 — modulos NVIDIA en el initramfs"

    local cur_modules cur_hooks
    cur_modules="$(grep -oP '^MODULES=\(\K[^)]*' "$MKINITCPIO_CONF" || true)"
    cur_hooks="$(grep -oP '^HOOKS=\(\K[^)]*' "$MKINITCPIO_CONF" || true)"

    grep -q '^MODULES=(.*)$' "$MKINITCPIO_CONF" \
        || die "MODULES= en $MKINITCPIO_CONF no esta en una sola linea; editalo a mano."
    grep -q '^HOOKS=(.*)$' "$MKINITCPIO_CONF" \
        || die "HOOKS= en $MKINITCPIO_CONF no esta en una sola linea; editalo a mano."

    # Conservamos lo que ya hubiera y agregamos los modulos NVIDIA al final,
    # sin repetirlos si ya estaban.
    local -a cur=() kept=()
    read -ra cur <<<"$cur_modules"
    local m
    for m in "${cur[@]}"; do
        case "$m" in
            nvidia|nvidia_modeset|nvidia_uvm|nvidia_drm) ;;
            *) kept+=("$m") ;;
        esac
    done
    local new_modules="${kept[*]:-} ${NVIDIA_MODULES[*]}"
    new_modules="${new_modules#"${new_modules%%[![:space:]]*}"}"

    # `kms` arrastraria nouveau al initramfs y pelearia con el modeset de NVIDIA.
    local -a hooks=() kept_hooks=()
    read -ra hooks <<<"$cur_hooks"
    local h
    for h in "${hooks[@]}"; do
        [[ "$h" == kms ]] && continue
        kept_hooks+=("$h")
    done
    local new_hooks="${kept_hooks[*]:-}"

    if [[ "$cur_modules" == "$new_modules" && "$cur_hooks" == "$new_hooks" ]]; then
        skip "mkinitcpio.conf ya esta como corresponde"
        return 0
    fi

    backup "$MKINITCPIO_CONF"
    root sed -i \
        -e "s|^MODULES=(.*)$|MODULES=($new_modules)|" \
        -e "s|^HOOKS=(.*)$|HOOKS=($new_hooks)|" \
        "$MKINITCPIO_CONF"

    info "MODULES=($new_modules)"
    [[ "$cur_hooks" != "$new_hooks" ]] && info "hook 'kms' removido de HOOKS"
    NEED_INITRAMFS=1
}


# █▀█ ▄▀█ █▀ █▀█   ▀█
# █▀▀ █▀█ ▄█ █▄█   ▄█

step3_suspend() {
    step "Paso 3 — preservar la VRAM al suspender"

    local desired
    desired="$(cat <<'CONF'
# Guarda el contenido de la VRAM al suspender/hibernar en lugar de dejar que el
# driver lo descarte. Sin esto Hyprland vuelve del suspend con las texturas
# corruptas, o directamente se cae.
#
# TemporaryFilePath apunta a /var/tmp porque /tmp es tmpfs y no sobrevive a la
# hibernacion.
options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
CONF
)"

    if [[ -f "$MODPROBE_CONF" && "$(cat "$MODPROBE_CONF")" == "$desired" ]]; then
        skip "${MODPROBE_CONF##*/} ya esta escrito"
    else
        backup "$MODPROBE_CONF"
        printf '%s\n' "$desired" | root_write "$MODPROBE_CONF"
        info "escrito $MODPROBE_CONF"
        # El hook `modconf` copia /etc/modprobe.d al initramfs, asi que el
        # cambio solo aplica desde el arranque temprano si rebuildeamos.
        NEED_INITRAMFS=1
    fi

    local svc
    for svc in "${SUSPEND_SERVICES[@]}"; do
        if [[ -z "$(systemctl list-unit-files --no-legend "$svc" 2>/dev/null)" ]]; then
            warn "$svc no existe en este sistema, lo salto"
            continue
        fi
        if systemctl is-enabled --quiet "$svc" 2>/dev/null; then
            skip "$svc ya habilitado"
        else
            root systemctl enable "$svc"
            info "$svc habilitado"
        fi
    done
}


# █▀█ ▄▀█ █▀ █▀█   ▄▀█
# █▀▀ █▀█ ▄█ █▄█   ▀▀█

step4_hyprland() {
    step "Paso 4 — variables de entorno de NVIDIA en Hyprland"

    if grep -q 'LIBVA_DRIVER_NAME' "$HYPR_CONF"; then
        skip "hyprland.lua ya tiene el bloque de NVIDIA"
        return 0
    fi

    # Se ancla al final del bloque de entorno existente para no partir la
    # seccion en dos.
    local anchor='hl.env("GDK_SCALE", "1")'
    grep -qF "$anchor" "$HYPR_CONF" \
        || die "No encuentro el ancla '$anchor' en hyprland.lua. Agrega el bloque a mano."

    local blockfile
    blockfile="$(mktemp_tracked)"
    cat >"$blockfile" <<'LUA'

-- NVIDIA (RTX 4070, driver propietario).
--
-- GBM_BACKEND=nvidia-drm se omite a proposito: con los drivers actuales ya no
-- hace falta y rompe la aceleracion de Firefox y Chromium. Tampoco hace falta
-- tocar cursor:no_hardware_cursors, que explicit sync dejo obsoleto.
hl.env("LIBVA_DRIVER_NAME", "nvidia")            -- VA-API sobre NVDEC
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")    -- GLX via libglvnd, no Mesa
hl.env("NVD_BACKEND", "direct")                  -- nvidia-vaapi-driver sin X
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")   -- Electron nativo en Wayland
LUA

    if (( DRY_RUN )); then
        printf '%s  [dry] insertaria despues de «%s»:%s\n' "$C_DIM" "$anchor" "$C_OFF"
        sed "s/^/${C_DIM}        /; s/\$/${C_OFF}/" "$blockfile"
        return 0
    fi

    backup "$HYPR_CONF" user

    local tmp
    tmp="$(mktemp_tracked)"
    awk -v anchor="$anchor" -v blockfile="$blockfile" '
        { print }
        !done && index($0, anchor) {
            while ((getline line < blockfile) > 0) print line
            close(blockfile)
            done = 1
        }
    ' "$HYPR_CONF" >"$tmp"

    grep -q 'LIBVA_DRIVER_NAME' "$tmp" || die "La insercion fallo; hyprland.lua quedo intacto."

    cat "$tmp" >"$HYPR_CONF"   # sobreescribe en sitio: conserva permisos e inodo
    info "4 variables agregadas a ${HYPR_CONF##*/}"
}


# █▀▀ █ █▄░█ ▄▀█ █░░
# █▀░ █ █░▀█ █▀█ █▄▄

rebuild_initramfs() {
    if (( ! NEED_INITRAMFS )); then
        step "Initramfs"
        skip "sin cambios que requieran regenerarlo"
        return 0
    fi
    step "Regenerando el initramfs"
    root mkinitcpio -P
}

summary() {
    step "Listo"
    cat <<'EOF'
  Reinicia y despues verifica:

    nvidia-smi                                  # driver vivo y version
    hyprctl systeminfo | grep -i gpu            # que Hyprland vea la 4070
    vulkaninfo --summary | grep -i deviceName   # ICD de Vulkan correcto
    lsinitcpio /boot/initramfs-linux.img | grep nvidia
    echo $LIBVA_DRIVER_NAME                     # dentro de la sesion Hyprland

  Pendientes que este script no toca:
    - Paso 5: Above 4G Decoding + Re-Size BAR en la BIOS
    - Paso 6b: acpi_enforce_resources=lax + it87 para los fans de la placa
EOF
}

main() {
    preflight
    step2_initramfs
    step3_suspend
    step4_hyprland
    rebuild_initramfs
    summary
}

main "$@"
