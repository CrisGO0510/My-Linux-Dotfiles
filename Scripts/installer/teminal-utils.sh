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
    # Shell y terminal
    zsh
    kitty
    curl
    wget
    stow

    # Herramientas modernas de CLI
    eza
    fd
    ripgrep
    fzf
    bat
    jq

    # File manager y previews
    lf
    glow
    ripdrag
    ffmpegthumbnailer
    poppler           # pdftoppm para preview de PDFs
    unzip
    unrar
    p7zip
    bsdtar
    zip               # lfrc usa zip para comprimir
    trash-cli         # lfrc mapea D a trash-confirm

    # System info
    fastfetch
    btop

    # Zsh plugins (paquetes de Arch)
    zsh-completions

    # Utilidades
    thefuck
    pokemon-colorscripts-git

    # Fuentes
    ttf-jetbrains-mono-nerd
    ttf-cascadia-code-nerd
    ttf-nerd-fonts-symbols-mono
)

for pkg in "${PACKAGES[@]}"; do
    if pacman -Qi $pkg &> /dev/null; then
        info "'$pkg' ya esta instalado."
    else
        info "Instalando '$pkg'..."
        yay -S --noconfirm $pkg
    fi
done

info "Todas las utilidades de terminal instaladas."
info "Ejecuta zsh-setup.sh para configurar Oh My Zsh y Powerlevel10k."
