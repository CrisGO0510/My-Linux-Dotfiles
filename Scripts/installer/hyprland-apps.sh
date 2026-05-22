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

# === Hyprland core ===
PACKAGES=(
    hyprland
    hyprlock
    hypridle
    hyprpaper
    hyprpicker
    hyprshade
    xdg-desktop-portal-hyprland

    # Bar y widgets
    eww

    # Notificaciones y launcher
    swaync
    rofi-wayland
    wlogout
    swayosd-git

    # Audio
    pipewire
    pipewire-pulse
    wireplumber
    pamixer
    pavucontrol

    # Red
    networkmanager
    nm-applet

    # Bluetooth
    bluez
    bluez-utils
    blueman

    # Clipboard
    wl-clipboard
    cliphist

    # Screenshot
    grim
    slurp
    swappy
    grimblast-git
    imagemagick

    # Brillo
    brightnessctl

    # Utilidades de sistema
    polkit-kde-agent
    udiskie
    jq
    socat
    lm_sensors
    playerctl
    qt5ct
    qt6ct
    nwg-look

    # Monitoreo GPU AMD (widget eww gpu_usage.sh)
    radeontop

    # Theming (referenciados en hyprland.conf)
    sweet-gtk-theme-dark
    candy-icons-git
    bibata-cursor-theme
    cantarell-fonts

    # Apps
    firefox
    bitwarden
    kitty

    # Multimedia
    mpv
    obs-studio
    cava
    spotify

    # Comunicacion
    vesktop
)

for pkg in "${PACKAGES[@]}"; do
    if pacman -Qi $pkg &> /dev/null; then
        info "'$pkg' ya esta instalado."
    else
        info "Instalando '$pkg'..."
        yay -S --noconfirm $pkg
    fi
done

# Habilitar servicios
info "Habilitando servicios..."
sudo systemctl enable --now NetworkManager 2>/dev/null || true
sudo systemctl enable --now bluetooth 2>/dev/null || true
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true

info "Todas las aplicaciones de Hyprland instaladas."
