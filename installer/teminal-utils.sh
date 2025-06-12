#!/bin/bash

set -e  # Detiene el script si ocurre un error

# Colores para mensajes
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

function info {
    echo -e "${GREEN}[INFO] $1${RESET}"
}

function error {
    echo -e "${RED}[ERROR] $1${RESET}"
}

# Comprobar si yay está instalado
if ! command -v yay &> /dev/null; then
    error "El gestor 'yay' no está instalado. Por favor, instálalo primero."
    exit 1
fi

# Actualizar el sistema
info "Actualizando sistema..."
yay -Syu --noconfirm

# Lista de paquetes a instalar
PACKAGES=(
    curl
    stow
    zsh
    kitty
    zsh-completions
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-256color
    eza
    fd
    ripgrep
    fzf
    bat
    ttf-jetbrains-mono-nerd
    ttf-cascadia-code-nerd
)

# Instalación de paquetes
for pkg in "${PACKAGES[@]}"; do
    if pacman -Qi $pkg &> /dev/null; then
        info "El paquete '$pkg' ya está instalado."
    else
        info "Instalando '$pkg' con yay..."
        yay -S --noconfirm $pkg
    fi
done

info "Todos los paquetes de utilidades de terminal han sido instalados correctamente."
