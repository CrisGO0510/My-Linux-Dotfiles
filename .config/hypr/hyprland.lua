--  ______     ______     __     ______
-- /\  ___\   /\  == \   /\ \   /\  ___\
-- \ \ \____  \ \  __<   \ \ \  \ \___  \
--  \ \_____\  \ \_\ \_\  \ \_\  \/\_____\
--   \/_____/   \/_/ /_/   \/_/   \/_____/
--
-- Config de Hyprland en Lua (hyprlang esta deprecado desde 0.55).
-- Wiki: https://wiki.hypr.land/Configuring/Start/

local HOME     = os.getenv("HOME")
local SCR_PATH = HOME .. "/dotfiles/Scripts/hypr"

-- El cursor queda confinado al monitor principal por una race-condition al
-- arrancar; una recarga diferida lo desbloquea.
local CURSOR_FIX_DELAY_MS = 2000


-- █░░ ▄▀█ █░█ █▄░█ █▀▀ █░█
-- █▄▄ █▀█ █▄█ █░▀█ █▄▄ █▀█

hl.on("hyprland.start", function()
    -- XDPH: reset del portal y propagacion del entorno a dbus/systemd
    hl.exec_cmd(SCR_PATH .. "/resetxdgportal.sh")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Dialogo de autenticacion para apps graficas
    hl.exec_cmd(SCR_PATH .. "/polkitkdeauth.sh")

    -- Bandeja del sistema
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("udiskie --no-automount --smart-tray")
    hl.exec_cmd("nm-applet --indicator")

    -- Portapapeles persistente (texto e imagen)
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Barra Quickshell: reemplaza a eww y es el servidor de notificaciones
    -- (por eso swaync ya no se lanza).
    hl.exec_cmd("qs -c bar")

    hl.exec_cmd(SCR_PATH .. "/wallpaper.sh")
    hl.exec_cmd("hypridle")

    hl.timer(function()
        hl.exec_cmd("hyprctl reload")
    end, { timeout = CURSOR_FIX_DELAY_MS, type = "oneshot" })
end)


-- █▀▀ █▄░█ █░█
-- ██▄ █░▀█ ▀▄▀

-- Los scripts de Scripts/hypr se invocan por nombre desde binds y menus.
local path = os.getenv("PATH") or ""
if not path:find(SCR_PATH, 1, true) then
    hl.env("PATH", path .. ":" .. SCR_PATH)
end

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("GDK_SCALE", "1")

-- NVIDIA (RTX 4070, driver propietario).
--
-- GBM_BACKEND=nvidia-drm se omite a proposito: con los drivers actuales ya no
-- hace falta y rompe la aceleracion de Firefox y Chromium. Tampoco hace falta
-- tocar cursor:no_hardware_cursors, que explicit sync dejo obsoleto.
hl.env("LIBVA_DRIVER_NAME", "nvidia")            -- VA-API sobre NVDEC
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")    -- GLX via libglvnd, no Mesa
hl.env("NVD_BACKEND", "direct")                  -- nvidia-vaapi-driver sin X
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")   -- Electron nativo en Wayland

-- El mapeo que SDL trae para el Acer NGR200 (0502:1305) asume el modo X-Input.
-- En modo APP el pad expone otros indices, asi que se sobreescribe con el real.
hl.env("SDL_GAMECONTROLLERCONFIG",
    "03008c63020500000513000010010000,Acer NGR200," ..
    "a:b0,b:b1,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,back:b8,start:b9," ..
    "leftstick:b10,rightstick:b11,dpup:b12,dpdown:b13,dpleft:b14,dpright:b15," ..
    "leftx:a0,lefty:a1,rightx:a2,righty:a3,lefttrigger:a5,righttrigger:a4," ..
    "platform:Linux,")


-- █ █▄░█ █▀█ █░█ ▀█▀   ░   █░░ ▄▀█ █▄█ █▀█ █░█ ▀█▀ █▀   ░   █▀▄▀█ █ █▀ █▀▀
-- █ █░▀█ █▀▀ █▄█ ░█░   ▄   █▄▄ █▀█ ░█░ █▄█ █▄█ ░█░ ▄█   ▄   █░▀░█ █ ▄█ █▄▄

hl.config({
    input = {
        kb_layout          = "us,latam",
        follow_mouse       = 1,
        sensitivity        = 0.3,
        force_no_accel     = false,
        numlock_by_default = true,

        touchpad = {
            natural_scroll = true,
        },
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        vrr                      = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
    },

    debug = {
        vfr = true,
    },

    xwayland = {
        force_zero_scaling = true,
    },
})

hl.device({
    name        = "epic mouse V1",
    sensitivity = -0.5,
})


-- █▀ █▀█ █░█ █▀█ █▀▀ █▀▀
-- ▄█ █▄█ █▄█ █▀▄ █▄▄ ██▄

-- Cada require() es un scope aislado: un error en uno no tumba a los demas.
-- El orden replica el bloque `source =` de la config antigua.
require("animations")
require("keybindings")
require("windowrules")
require("themes.common")
require("themes.theme")
require("monitors")
