#!/bin/bash
set -e

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

function info { echo -e "${GREEN}[INFO] $1${RESET}"; }
function warn { echo -e "${YELLOW}[WARN] $1${RESET}"; }
function error { echo -e "${RED}[ERROR] $1${RESET}"; }

# Verificar que zsh esta instalado
if ! command -v zsh &>/dev/null; then
    error "zsh no esta instalado. Ejecuta teminal-utils.sh primero."
    exit 1
fi

# === Oh My Zsh ===
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    warn "Oh My Zsh ya esta instalado en ~/.oh-my-zsh"
else
    info "Instalando Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    info "Oh My Zsh instalado"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# === Powerlevel10k ===
if [[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
    warn "Powerlevel10k ya esta instalado"
else
    info "Instalando Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    info "Powerlevel10k instalado"
fi

# === Plugins de zsh (los que espera .zshrc) ===
declare -A PLUGINS=(
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions.git"
    ["zsh-256color"]="https://github.com/chrissicool/zsh-256color.git"
)

for plugin in "${!PLUGINS[@]}"; do
    if [[ -d "$ZSH_CUSTOM/plugins/$plugin" ]]; then
        warn "Plugin '$plugin' ya esta instalado"
    else
        info "Instalando plugin '$plugin'..."
        git clone --depth=1 "${PLUGINS[$plugin]}" "$ZSH_CUSTOM/plugins/$plugin"
        info "Plugin '$plugin' instalado"
    fi
done

# === Cambiar shell por defecto a zsh ===
CURRENT_SHELL=$(basename "$SHELL")
if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    warn "zsh ya es tu shell por defecto"
else
    info "Cambiando shell por defecto a zsh..."
    chsh -s "$(which zsh)"
    info "Shell cambiado a zsh. Cierra sesion y vuelve a entrar para que tome efecto."
fi

echo ""
info "=== Setup completo ==="
info "  - Oh My Zsh: ~/.oh-my-zsh"
info "  - Powerlevel10k: $ZSH_CUSTOM/themes/powerlevel10k"
info "  - Plugins: zsh-syntax-highlighting, zsh-autosuggestions, zsh-256color"
info "  - Shell por defecto: zsh"
echo ""
info "Ejecuta 'p10k configure' para configurar el tema si es la primera vez."
