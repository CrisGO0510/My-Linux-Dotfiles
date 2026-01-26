#!/usr/bin/env sh

# Azure Dreams Rofi Launcher
# Updated to use unified config.rasi with Azure Dreams theme

# Configuración base
confDir="${XDG_CONFIG_HOME:-$HOME/.config}"
rofiScale="10"
hypr_border="2"

# Use new unified Azure Dreams config
roconf="${confDir}/rofi/config.rasi"

# Check if Azure Dreams config exists, fallback to backup if needed
if [ ! -f "${roconf}" ] ; then
    echo "⚠️  Azure Dreams config not found, checking for backup..."
    if [ -d "${confDir}/rofi_backup_complete" ] ; then
        echo "📁 Using backup configuration"
        roconf="${confDir}/rofi_backup_complete/styles/style_1.rasi"
    else
        echo "❌ No Rofi configuration found!"
        exit 1
    fi
fi

[[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10

# rofi action
case "${1}" in
    d|--drun) r_mode="drun" ;; 
    w|--window) r_mode="window" ;;
    f|--filebrowser) r_mode="filebrowser" ;;
    h|--help) echo -e "$(basename "${0}") [action]"
        echo "d :  drun mode"
        echo "w :  window mode"
        echo "f :  filebrowser mode"
        echo ""
        echo "🎨 Using Azure Dreams theme from: ${roconf}"
        exit 0 ;;
    *) r_mode="drun" ;;
esac

# set overrides (preserved for compatibility)
wind_border=$(( hypr_border * 3 ))
[ "${hypr_border}" -eq 0 ] && elem_border="10" || elem_border=$(( hypr_border * 2 ))
r_override="window {border: 1px; border-radius: ${wind_border}px;} element {border-radius: ${elem_border}px;}"
r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"
i_override="$(gsettings get org.gnome.desktop.interface icon-theme | sed "s/'//g")"
i_override="configuration {icon-theme: \"${i_override}\";}"

# launch rofi with Azure Dreams theme
rofi -show "${r_mode}" -theme-str "${r_scale}" -theme-str "${r_override}" -theme-str "${i_override}" -config "${roconf}"
