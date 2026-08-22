-- █▀▀ █░█ █▀█ █▀ █▀█ █▀█
-- █▄▄ █▄█ █▀▄ ▄█ █▄█ █▀▄

local CURSOR_THEME = "Bibata-Modern-Ice"
local CURSOR_SIZE  = 20

local FONT_UI       = "Cantarell 10"
local FONT_DOCUMENT = "Cantarell 10"
local FONT_MONO     = "CaskaydiaCove Nerd Font Mono 9"

-- Se ejecutan en cada carga de la config, igual que hacia `exec =`.
hl.exec_cmd("hyprctl setcursor " .. CURSOR_THEME .. " " .. CURSOR_SIZE)
hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme '" .. CURSOR_THEME .. "'")
hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size " .. CURSOR_SIZE)


-- █▀▀ █▀█ █▄░█ ▀█▀
-- █▀░ █▄█ █░▀█ ░█░

hl.exec_cmd("gsettings set org.gnome.desktop.interface font-name '" .. FONT_UI .. "'")
hl.exec_cmd("gsettings set org.gnome.desktop.interface document-font-name '" .. FONT_DOCUMENT .. "'")
hl.exec_cmd("gsettings set org.gnome.desktop.interface monospace-font-name '" .. FONT_MONO .. "'")
hl.exec_cmd("gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'")
hl.exec_cmd("gsettings set org.gnome.desktop.interface font-hinting 'full'")


-- █▀ █▀█ █▀▀ █▀▀ █ ▄▀█ █░░
-- ▄█ █▀▀ ██▄ █▄▄ █ █▀█ █▄▄

hl.config({
    decoration = {
        dim_special = 0.3,
        blur = {
            special = true,
        },
    },
})
