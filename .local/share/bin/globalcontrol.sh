if printenv HYPRLAND_INSTANCE_SIGNATURE &> /dev/null; then
    export hypr_border="$(hyprctl -j getoption decoration:rounding | jq '.int')"
    export hypr_width="$(hyprctl -j getoption general:border_size | jq '.int')"
fi

pkg_installed()
{
    local pkgIn=$1
    if pacman -Qi "${pkgIn}" &> /dev/null ; then
        return 0
    elif pacman -Qi "flatpak" &> /dev/null && flatpak info "${pkgIn}" &> /dev/null ; then
        return 0
    elif command -v "${pkgIn}" &> /dev/null ; then
        return 0
    else
        return 1
    fi
}

get_aurhlpr()
{
    if pkg_installed yay
    then
        aurhlpr="yay"
    elif pkg_installed paru
    then
        aurhlpr="paru"
    fi
}
