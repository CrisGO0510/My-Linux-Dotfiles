#!/bin/bash
# Hibernacion + suspend-then-hibernate.
#
# El equipo suspende a S3 y, pasado HIBERNATE_DELAY, vuelca la RAM al disco y
# se apaga del todo (0 W). La sesion sobrevive aunque se agote la bateria.
#
# Monta las cuatro piezas que la hibernacion necesita:
#   1. un swapfile en disco (zram no sirve: vive en la RAM que hay que volcar)
#   2. resume= y resume_offset= en el cmdline, para que el kernel sepa de donde
#      reanudar
#   3. el hook `resume` en el initramfs, que hace la reanudacion
#   4. HibernateDelaySec, que define cuanto espera suspendido antes de hibernar
#
# Idempotente: se puede reejecutar sin duplicar nada.

set -e

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

function info  { echo -e "${GREEN}[INFO]${RESET} $1"; }
function warn  { echo -e "${YELLOW}[WARN]${RESET} $1"; }
function error { echo -e "${RED}[ERROR]${RESET} $1"; }
function step  { echo -e "\n${BLUE}=== $1 ===${RESET}"; }

SWAPFILE="/swapfile"
SWAPFILE_SIZE="32G"
SWAPFILE_PRIORITY="-2"          # por debajo de zram (100): zram se usa primero
HIBERNATE_DELAY="10min"

FSTAB="/etc/fstab"
GRUB_DEFAULTS="/etc/default/grub"
GRUB_CFG="/boot/grub/grub.cfg"
MKINITCPIO_CONF="/etc/mkinitcpio.conf"
INITRAMFS="/boot/initramfs-linux.img"
SLEEP_DROPIN_DIR="/etc/systemd/sleep.conf.d"
SLEEP_DROPIN="$SLEEP_DROPIN_DIR/10-hibernate-delay.conf"
BACKUP_SUFFIX=".dotfiles-bak-$(date +%Y%m%d%H%M%S)"

if [[ $EUID -eq 0 ]]; then
    error "No ejecutes este script como root. Pedira sudo cuando lo necesite."
    exit 1
fi


# === Comprobaciones previas ===
step "Comprobaciones"

lockdown=$(cat /sys/kernel/security/lockdown 2>/dev/null || echo "[none]")
if [[ "$lockdown" != *"[none]"* ]]; then
    error "El kernel esta en lockdown ($lockdown): la hibernacion esta bloqueada."
    exit 1
fi

if ! grep -qw disk /sys/power/state; then
    error "El kernel no ofrece hibernacion (falta 'disk' en /sys/power/state)."
    exit 1
fi

root_fstype=$(findmnt -no FSTYPE /)
if [[ "$root_fstype" != "ext4" ]]; then
    error "Este script asume / en ext4; encontrado: $root_fstype."
    error "En btrfs el offset se calcula distinto (btrfs inspect-internal)."
    exit 1
fi

root_uuid=$(findmnt -no UUID /)
if [[ -z "$root_uuid" ]]; then
    error "No se pudo determinar el UUID de /."
    exit 1
fi

for cmd in filefrag mkswap mkinitcpio grub-mkconfig; do
    command -v "$cmd" &>/dev/null || { error "Falta el comando '$cmd'."; exit 1; }
done

free_gib=$(df --output=avail -BG / | tail -1 | tr -dc '0-9')
needed_gib=${SWAPFILE_SIZE%G}
if [[ -z "$free_gib" || "$free_gib" -lt $((needed_gib + 10)) ]]; then
    error "Espacio insuficiente en /: ${free_gib}G libres, hacen falta $((needed_gib + 10))G."
    exit 1
fi

info "/ es ext4 (UUID=$root_uuid), ${free_gib}G libres. Todo correcto."


# === 1. Swapfile ===
step "Swapfile de $SWAPFILE_SIZE"

if [[ -f "$SWAPFILE" ]]; then
    info "$SWAPFILE ya existe; no se recrea."
else
    info "Creando $SWAPFILE (puede tardar)..."
    sudo mkswap -U clear --size "$SWAPFILE_SIZE" --file "$SWAPFILE"
fi

sudo chmod 600 "$SWAPFILE"

if ! swapon --show=NAME --noheadings | grep -qx "$SWAPFILE"; then
    sudo swapon --priority "$SWAPFILE_PRIORITY" "$SWAPFILE"
    info "Swapfile activado."
else
    info "Swapfile ya activo."
fi

if grep -q "^$SWAPFILE[[:space:]]" "$FSTAB"; then
    info "$FSTAB ya tiene la entrada del swapfile."
else
    info "Añadiendo el swapfile a $FSTAB (backup en $FSTAB$BACKUP_SUFFIX)"
    sudo cp "$FSTAB" "$FSTAB$BACKUP_SUFFIX"
    printf '\n# swapfile para hibernacion (dotfiles: hibernate-setup.sh)\n%s none swap defaults,pri=%s 0 0\n' \
        "$SWAPFILE" "$SWAPFILE_PRIORITY" | sudo tee -a "$FSTAB" >/dev/null
fi


# === 2. resume= y resume_offset= en el cmdline ===
step "Parametros de reanudacion en GRUB"

resume_offset=$(sudo filefrag -v "$SWAPFILE" | awk '$1=="0:" {print substr($4, 1, length($4)-2)}')
if [[ -z "$resume_offset" || ! "$resume_offset" =~ ^[0-9]+$ ]]; then
    error "No se pudo calcular resume_offset del swapfile."
    exit 1
fi
info "resume=UUID=$root_uuid  resume_offset=$resume_offset"

if grep -q "resume=UUID=$root_uuid" "$GRUB_DEFAULTS" && \
   grep -q "resume_offset=$resume_offset" "$GRUB_DEFAULTS"; then
    info "$GRUB_DEFAULTS ya tiene los parametros correctos."
else
    info "Actualizando $GRUB_DEFAULTS (backup en $GRUB_DEFAULTS$BACKUP_SUFFIX)"
    sudo cp "$GRUB_DEFAULTS" "$GRUB_DEFAULTS$BACKUP_SUFFIX"
    # Se limpian valores previos para no acumular duplicados al reejecutar.
    sudo sed -i -E \
        -e 's/[[:space:]]*resume=[^ "]*//g' \
        -e 's/[[:space:]]*resume_offset=[^ "]*//g' \
        -e "s|^(GRUB_CMDLINE_LINUX_DEFAULT=\")(.*)(\")|\1\2 resume=UUID=$root_uuid resume_offset=$resume_offset\3|" \
        "$GRUB_DEFAULTS"
    grep -E "^GRUB_CMDLINE_LINUX_DEFAULT" "$GRUB_DEFAULTS"
fi


# === 3. Hook resume en el initramfs ===
step "Hook 'resume' en $MKINITCPIO_CONF"

if grep -qE "^HOOKS=.*[( ]resume[ )]" "$MKINITCPIO_CONF"; then
    info "El hook 'resume' ya esta presente."
else
    info "Añadiendo 'resume' tras 'block' (backup en $MKINITCPIO_CONF$BACKUP_SUFFIX)"
    sudo cp "$MKINITCPIO_CONF" "$MKINITCPIO_CONF$BACKUP_SUFFIX"
    sudo sed -i -E "s/^(HOOKS=\(.*\bblock\b)(.*)$/\1 resume\2/" "$MKINITCPIO_CONF"
    grep -E "^HOOKS" "$MKINITCPIO_CONF"
fi

if ! grep -qE "^HOOKS=.*[( ]resume[ )]" "$MKINITCPIO_CONF"; then
    error "No se pudo insertar el hook 'resume'. Revisa $MKINITCPIO_CONF a mano."
    exit 1
fi


# === 4. Retardo antes de hibernar ===
step "HibernateDelaySec=$HIBERNATE_DELAY"

sudo mkdir -p "$SLEEP_DROPIN_DIR"
sudo tee "$SLEEP_DROPIN" >/dev/null <<EOF
# Gestionado por dotfiles (Scripts/installer/hibernate-setup.sh).
# suspend-then-hibernate: S3 durante este tiempo, luego hibernacion a 0 W.
[Sleep]
HibernateDelaySec=$HIBERNATE_DELAY
EOF
info "Escrito $SLEEP_DROPIN"


# === 5. Regenerar initramfs y grub.cfg ===
step "Regenerando initramfs y grub.cfg"

# Solo existe el preset 'default' (sin fallback): sin copia de seguridad, un
# initramfs malo dejaria el equipo sin forma de arrancar.
if [[ -f "$INITRAMFS" ]]; then
    info "Backup del initramfs actual en $INITRAMFS$BACKUP_SUFFIX"
    sudo cp "$INITRAMFS" "$INITRAMFS$BACKUP_SUFFIX"
fi

sudo mkinitcpio -P
sudo grub-mkconfig -o "$GRUB_CFG"

cat <<EOF

${GREEN}Configuracion aplicada.${RESET} Falta reiniciar para que el kernel arranque con
resume= y con el nuevo initramfs.

Despues del reinicio, comprueba en este orden:

  1. Que los parametros llegaron:
       grep -o 'resume[^ ]*' /proc/cmdline

  2. Que la hibernacion funciona (guarda tu trabajo antes):
       systemctl hibernate
     El equipo debe apagarse del todo y, al encenderlo, volver a tu sesion.

  3. Que el ciclo completo funciona:
       systemctl suspend-then-hibernate

Si algo sale mal, los backups de esta ejecucion tienen el sufijo:
  $BACKUP_SUFFIX

Para revertir por completo:
  sudo swapoff $SWAPFILE && sudo rm $SWAPFILE
  sudo rm $SLEEP_DROPIN
  restaura $FSTAB, $GRUB_DEFAULTS y $MKINITCPIO_CONF desde sus backups
  sudo mkinitcpio -P && sudo grub-mkconfig -o $GRUB_CFG

EOF
