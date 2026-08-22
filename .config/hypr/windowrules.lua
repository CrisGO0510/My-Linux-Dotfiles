-- █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█   █▀█ █░█ █░░ █▀▀ █▀
-- ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀   █▀▄ █▄█ █▄▄ ██▄ ▄█
--
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- "override" fija la opacidad en absoluto; sin el, multiplica sobre la que ya
-- tenga la ventana. El orden de los valores es activa / inactiva / completa.
local OPACITY_BROWSER  = "0.90 override 0.90 override 1"
local OPACITY_APP      = "0.80 override 0.80 override 1"
local OPACITY_UTILITY  = "0.80 override 0.70 override 1"
local OPACITY_MEDIA    = "0.70 override 0.70 override 1"

-- Estas si multiplican (comportamiento historico distinto, no unificar).
local OPACITY_SCALED_HIGH = "0.90 0.90"
local OPACITY_SCALED_APP  = "0.80 0.80"

local function applyOpacity(opacity, classes)
    for _, class in ipairs(classes) do
        hl.window_rule({ match = { class = class }, opacity = opacity })
    end
end

local function floatClasses(classes)
    for _, class in ipairs(classes) do
        hl.window_rule({ match = { class = class }, float = true })
    end
end

local function floatTitles(titles)
    for _, title in ipairs(titles) do
        hl.window_rule({ match = { title = title }, float = true })
    end
end


-- █▀█ █▀█ ▄▀█ █▀▀ █ █▀▄ ▄▀█ █▀▄
-- █▄█ █▀▀ █▀█ █▄▄ █ █▄▀ █▀█ █▄▀

applyOpacity(OPACITY_BROWSER, {
    "^(firefox)$",
    "^(Brave-browser)$",
})

applyOpacity(OPACITY_APP, {
    "^(code-oss)$",
    "^([Cc]ode)$",
    "^(code-url-handler)$",
    "^(code-insiders-url-handler)$",
    "^(kitty)$",
    "^(org.kde.dolphin)$",
    "^(org.kde.ark)$",
    "^(nwg-look)$",
    "^(qt5ct)$",
    "^(qt6ct)$",
    "^(kvantummanager)$",
})

applyOpacity(OPACITY_UTILITY, {
    "^(org.pulseaudio.pavucontrol)$",
    "^(blueman-manager)$",
    "^(nm-applet)$",
    "^(nm-connection-editor)$",
    "^(org.kde.polkit-kde-authentication-agent-1)$",
    "^(polkit-gnome-authentication-agent-1)$",
    "^(org.freedesktop.impl.portal.desktop.gtk)$",
    "^(org.freedesktop.impl.portal.desktop.hyprland)$",
})

applyOpacity(OPACITY_MEDIA, {
    "^([Ss]team)$",
    "^(steamwebhelper)$",
    "^([Ss]potify)$",
})

-- Spotify no expone su clase hasta despues de arrancar; se ataca por titulo inicial.
for _, title in ipairs({ "^(Spotify Free)$", "^(Spotify Premium)$" }) do
    hl.window_rule({ match = { initial_title = title }, opacity = OPACITY_MEDIA })
end

applyOpacity(OPACITY_SCALED_HIGH, {
    "^(com.github.rafostar.Clapper)$", -- Clapper-Gtk
})

applyOpacity(OPACITY_SCALED_APP, {
    "^(com.github.tchx84.Flatseal)$",           -- Flatseal-Gtk
    "^(hu.kramo.Cartridges)$",                  -- Cartridges-Gtk
    "^(com.obsproject.Studio)$",                -- Obs-Qt
    "^(gnome-boxes)$",                          -- Boxes-Gtk
    "^(vesktop)$",                              -- Vesktop
    "^(discord)$",                              -- Discord-Electron
    "^(WebCord)$",                              -- WebCord-Electron
    "^(ArmCord)$",                              -- ArmCord-Electron
    "^(app.drey.Warp)$",                        -- Warp-Gtk
    "^(net.davidotek.pupgui2)$",                -- ProtonUp-Qt
    "^(yad)$",                                  -- Protontricks-Gtk
    "^(Signal)$",                               -- Signal-Gtk
    "^(io.github.alainm23.planify)$",           -- planify-Gtk
    "^(io.gitlab.theevilskeleton.Upscaler)$",   -- Upscaler-Gtk
    "^(com.github.unrud.VideoDownloader)$",     -- VideoDownloader-Gtk
    "^(io.gitlab.adhami3310.Impression)$",      -- Impression-Gtk
    "^(io.missioncenter.MissionCenter)$",       -- MissionCenter-Gtk
    "^(io.github.flattool.Warehouse)$",         -- Warehouse-Gtk
})


-- █▀▀ █░░ █▀█ ▀█▀ ▄▀█ █▄░█ ▀█▀ █▀▀ █▀
-- █▀░ █▄▄ █▄█ ░█░ █▀█ █░▀█ ░█░ ██▄ ▄█

-- Dialogos y ventanas auxiliares que no deben entrar en el tiling.
for _, rule in ipairs({
    { class = "^(org.kde.dolphin)$", title = "^(Progress Dialog — Dolphin)$" },
    { class = "^(org.kde.dolphin)$", title = "^(Copying — Dolphin)$" },
    { class = "^(firefox)$",         title = "^(Picture-in-Picture)$" },
    { class = "^(firefox)$",         title = "^(Library)$" },
    { class = "^(kitty)$",           title = "^(top)$" },
    { class = "^(kitty)$",           title = "^(btop)$" },
    { class = "^(kitty)$",           title = "^(htop)$" },
}) do
    hl.window_rule({ match = rule, float = true })
end

floatClasses({
    "^(vlc)$",
    "^(kvantummanager)$",
    "^(qt5ct)$",
    "^(qt6ct)$",
    "^(nwg-look)$",
    "^(org.kde.ark)$",
    "^(org.pulseaudio.pavucontrol)$",
    "^(blueman-manager)$",
    "^(nm-applet)$",
    "^(nm-connection-editor)$",
    "^(org.kde.polkit-kde-authentication-agent-1)$",
    "^(xdg-desktop-portal-gtk)$",
    "^(Signal)$",                             -- Signal-Gtk
    "^(com.github.rafostar.Clapper)$",        -- Clapper-Gtk
    "^(app.drey.Warp)$",                      -- Warp-Gtk
    "^(net.davidotek.pupgui2)$",              -- ProtonUp-Qt
    "^(yad)$",                                -- Protontricks-Gtk
    "^(eog)$",                                -- Imageviewer-Gtk
    "^(io.github.alainm23.planify)$",         -- planify-Gtk
    "^(io.gitlab.theevilskeleton.Upscaler)$", -- Upscaler-Gtk
    "^(com.github.unrud.VideoDownloader)$",   -- VideoDownloader-Gtk
    "^(io.gitlab.adhami3310.Impression)$",    -- Impression-Gtk
    "^(io.missioncenter.MissionCenter)$",     -- MissionCenter-Gtk
})

floatTitles({
    "^(About Mozilla Firefox)$",
    "^(Choose Files)$",
    "^(Save As)$",
    "^(Confirm to replace files)$",
    "^(File Operation Progress)$",
})

hl.window_rule({ match = { initial_title = "^(Open File)$" }, float = true })


-- █░░ ▄▀█ █▄█ █▀▀ █▀█ █▀
-- █▄▄ █▀█ ░█░ ██▄ █▀▄ ▄█

-- Capas de Quickshell: barra, notificaciones y lockscreen.
for _, namespace in ipairs({ "quickshell-lock", "quickshell-bar", "quickshell-notif" }) do
    hl.layer_rule({ match = { namespace = namespace }, blur = true, ignore_alpha = 0 })
end
