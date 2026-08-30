#!/bin/bash
# Orquestador de instalacion del ecosistema dotfiles
# Ejecuta los scripts del directorio en el orden correcto.

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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# === Pre-checks ===
if [[ $EUID -eq 0 ]]; then
    error "No ejecutes este script como root. Pedira sudo cuando lo necesite."
    exit 1
fi

if ! command -v pacman &>/dev/null; then
    error "Este script requiere Arch Linux (pacman no encontrado)."
    exit 1
fi

if ! ping -q -c 1 -W 2 8.8.8.8 &>/dev/null; then
    error "No hay conexion a internet."
    exit 1
fi

# === Confirmacion ===
cat <<EOF

${BLUE}Instalador del ecosistema dotfiles${RESET}
Se ejecutaran en orden:
  1. base-devel + git (prerequisito)
  2. yay (AUR helper) si no esta instalado
  3. chaotic_aur.sh        (opcional, requiere sudo)
  4. teminal-utils.sh      (zsh, kitty, eza, fzf, btop, etc.)
  5. zsh-setup.sh          (Oh My Zsh + Powerlevel10k + plugins)
  6. hyprland-apps.sh      (Hyprland + utilidades + multimedia)
  7. coding-needs.sh       (nodejs, rust, python, neovim)
  8. lid-behavior.sh       (cerrar la tapa no suspende; requiere sudo)
  9. stow                  (symlinks de dotfiles a \$HOME)

EOF
read -rp "Continuar? [y/N] " ans
[[ "$ans" =~ ^[Yy]$ ]] || { warn "Cancelado."; exit 0; }

# === 1. base-devel + git ===
step "Instalando base-devel y git"
sudo pacman -S --needed --noconfirm base-devel git

# === 2. yay ===
step "Verificando AUR helper"
if command -v yay &>/dev/null; then
    info "yay ya esta instalado."
elif command -v paru &>/dev/null; then
    info "paru detectado; se usara en lugar de yay."
else
    info "Instalando yay desde AUR..."
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    (cd "$tmpdir/yay" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
fi

# === 3. Chaotic AUR (opcional) ===
step "Chaotic AUR (opcional)"
read -rp "Instalar Chaotic AUR? [y/N] " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
    sudo "$SCRIPT_DIR/chaotic_aur.sh" --install fresh
else
    info "Saltando Chaotic AUR."
fi

# === 4-7. Scripts de instalacion ===
run_script() {
    local script="$1"
    local label="$2"
    step "$label"
    if [[ -x "$SCRIPT_DIR/$script" ]]; then
        bash "$SCRIPT_DIR/$script"
    else
        error "$script no es ejecutable o no existe."
        return 1
    fi
}

run_script "teminal-utils.sh" "Utilidades de terminal"
run_script "zsh-setup.sh"     "Oh My Zsh + Powerlevel10k"
run_script "hyprland-apps.sh" "Hyprland y apps de escritorio"
run_script "coding-needs.sh"  "Herramientas de desarrollo"
run_script "lid-behavior.sh"  "Comportamiento del cierre de tapa"

# === 9. Stow ===
step "Aplicando symlinks con stow"
if ! command -v stow &>/dev/null; then
    error "stow no encontrado. Algo fallo en teminal-utils.sh"
    exit 1
fi

cd "$DOTFILES_DIR"
warn "Esto creara symlinks de $DOTFILES_DIR hacia \$HOME."
warn "Si hay conflictos puedes usar 'stow . --adopt' y luego 'git reset --hard'."
read -rp "Ejecutar 'stow .' ahora? [y/N] " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
    stow . || warn "stow reporto conflictos. Revisa manualmente."
else
    info "Saltando stow. Ejecutalo despues con: cd $DOTFILES_DIR && stow ."
fi

echo ""
info "=== Instalacion completa ==="
info "Cierra sesion y vuelve a entrar para que zsh y Hyprland tomen efecto."
info "Ejecuta 'p10k configure' para personalizar el prompt si es la primera vez."
echo ""
info "Pasos manuales pendientes para Neovim:"
info "  1. Abri nvim → Lazy instala plugins automaticamente."
info "  2. :Mason          → instala los LSPs (ts_ls, vue_ls, angularls, etc.)"
info "  3. :Copilot setup  → autenticate con GitHub (requiere suscripcion Copilot)"
