-- ▀█▀ █▀▀ █▀▄▀█ ▄▀█
-- ░█░ ██▄ █░▀░█ █▀█

local GTK_THEME    = "Sweet-Dark"
local ICON_THEME   = "candy-icons"
local COLOR_SCHEME = "prefer-dark"

-- Gradiente morado -> rojo para lo activo, cian -> azul para lo inactivo.
local BORDER_ACTIVE   = { colors = { "rgba(c74dedff)", "rgba(ed254eff)" }, angle = 45 }
local BORDER_INACTIVE = { colors = { "rgba(00c1e4cc)", "rgba(7cb7ffcc)" }, angle = 45 }

hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme '" .. ICON_THEME .. "'")
hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme '" .. GTK_THEME .. "'")
hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme '" .. COLOR_SCHEME .. "'")

hl.config({
    general = {
        gaps_in          = 3,
        gaps_out         = 8,
        border_size      = 2,
        layout           = "dwindle",
        resize_on_border = true,

        col = {
            active_border   = BORDER_ACTIVE,
            inactive_border = BORDER_INACTIVE,
        },
    },

    decoration = {
        rounding = 10,

        blur = {
            enabled           = true,
            size              = 6,
            passes            = 3,
            new_optimizations = true,
            ignore_opacity    = true,
            xray              = false,
        },

        shadow = {
            enabled = false,
        },
    },
})
