#!/bin/bash

set -e

GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

function info { echo -e "${GREEN}[INFO] $1${RESET}"; }
function error { echo -e "${RED}[ERROR] $1${RESET}"; }

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

info "Todas las herramientas de desarrollo instaladas."
