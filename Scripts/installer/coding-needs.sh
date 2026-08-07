#!/bin/bash

set -e

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

function info { echo -e "${GREEN}[INFO] $1${RESET}"; }
function warn { echo -e "${YELLOW}[WARN] $1${RESET}"; }
function error { echo -e "${RED}[ERROR] $1${RESET}"; }

# Diccionarios de nvim: sin ellos, cada markdown que se abre pregunta si
# descargarlos (config/autocmds.lua activa spell con spelllang=es,en).
SPELL_DIR="$HOME/.local/share/nvim/site/spell"
SPELL_MIRROR="https://ftp.nluug.nl/pub/vim/runtime/spell"
SPELL_FILES=(
    es.utf-8.spl
    es.utf-8.sug
    en.utf-8.spl
    en.utf-8.sug
)

if ! command -v yay &> /dev/null; then
    error "El gestor 'yay' no esta instalado."
    exit 1
fi

info "Actualizando sistema..."
yay -Syu --noconfirm

PACKAGES=(
    git
    neovim
    python
    python-pip

    # Node
    nodejs
    npm

    # Rust
    rustup

    # Utilidades de dev
    direnv
    base-devel

    # Formatters para nvim (conform.nvim)
    stylua
    prettier
    python-black

    # Treesitter (compila parsers desde main branch)
    tree-sitter-cli
)

for pkg in "${PACKAGES[@]}"; do
    if pacman -Qi $pkg &> /dev/null; then
        info "'$pkg' ya esta instalado."
    else
        info "Instalando '$pkg'..."
        yay -S --noconfirm $pkg
    fi
done

# Configurar Rust toolchain
if command -v rustup &>/dev/null; then
    if rustup toolchain list | grep -q stable; then
        info "Rust stable toolchain ya configurado."
    else
        info "Instalando Rust stable toolchain..."
        rustup default stable
    fi
fi

# Diccionarios de correccion ortografica para nvim
info "Verificando diccionarios de nvim (espanol e ingles)..."
mkdir -p "$SPELL_DIR"
for spell in "${SPELL_FILES[@]}"; do
    if [[ -s "$SPELL_DIR/$spell" ]]; then
        info "'$spell' ya esta descargado."
    elif curl -fsSL -o "$SPELL_DIR/$spell" "$SPELL_MIRROR/$spell"; then
        info "'$spell' descargado."
    else
        rm -f "$SPELL_DIR/$spell"
        warn "No se pudo descargar '$spell'. nvim lo pedira al abrir un markdown."
    fi
done

info "Todas las herramientas de desarrollo instaladas."
