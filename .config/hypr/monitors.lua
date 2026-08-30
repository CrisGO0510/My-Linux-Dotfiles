-- █▀▄▀█ █▀█ █▄░█ █ ▀█▀ █▀█ █▀█ █▀
-- █░▀░█ █▄█ █░▀█ █ ░█░ █▄█ █▀▄ ▄█
--
-- Perfil auto-detectado: un solo archivo sirve para el desktop y la laptop,
-- asi que esta config deja de divergir entre ramas.
--
-- La deteccion lee /sys/class/drm en vez de hl.get_monitors() porque este
-- archivo se evalua durante el arranque, antes de que Hyprland enumere las
-- salidas.

local MAX_DRM_CARD = 4

--- Estado DRM de una salida, sin depender del indice de la tarjeta.
--- @param output string Nombre del conector (ej. "eDP-1")
--- @return boolean
local function is_connected(output)
    for card = 0, MAX_DRM_CARD do
        local path = string.format("/sys/class/drm/card%d-%s/status", card, output)
        local ok, handle = pcall(io.open, path, "r")
        if ok and handle then
            local status = handle:read("*l")
            handle:close()
            if status == "connected" then
                return true
            end
        end
    end
    return false
end


-- █▀█ █▀▀ █▀█ █▀▀ █ █░░ █▀▀ █▀
-- █▀▀ █▄▄ █▀▄ █▀░ █ █▄▄ ██▄ ▄█
--
-- `marker` es la salida que solo existe en esa maquina. En ambas la principal
-- es HDMI-A-1, lo unico que cambia es la secundaria.

local PROFILES = {
    {
        name      = "laptop",
        marker    = "eDP-1",
        primary   = { output = "HDMI-A-1", mode = "1920x1080@60", position = "0x0",    scale = 1 },
        secondary = { output = "eDP-1",    mode = "1920x1080@60", position = "1920x0", scale = 1.5 },
    },
    {
        name      = "desktop",
        marker    = "DP-1",
        -- HDMI-A-1 (ML2022CM) a la izquierda; DP-1 (LG HD) a su derecha,
        -- centrado verticalmente: (1080 - 768) / 2 = 156.
        primary   = { output = "HDMI-A-1", mode = "1920x1080@75", position = "0x0",      scale = 1 },
        secondary = { output = "DP-1",     mode = "1366x768@60",  position = "1920x156", scale = 1 },
    },
}

local profile
for _, candidate in ipairs(PROFILES) do
    if is_connected(candidate.marker) then
        profile = candidate
        break
    end
end

if profile then
    hl.monitor(profile.primary)
    hl.monitor(profile.secondary)
else
    -- Sin perfil reconocido dejamos que Hyprland resuelva las salidas solo,
    -- antes que forzar un layout equivocado.
    hl.notification.create({
        text    = "monitors.lua: ningun perfil coincide, usando defaults de Hyprland",
        timeout = 8000,
    })
end


-- ▄▀█ █▀ █ █▀▀ █▄░█ ▄▀█ █▀▀ █ █▀█ █▄░█   █▀▄ █▀▀   █░█░█ █▀
-- █▀█ ▄█ █ █▄█ █░▀█ █▀█ █▄▄ █ █▄█ █░▀█   █▄▀ ██▄   ▀▄▀▄▀ ▄█
--
-- Impares en la principal, pares en la secundaria.

local WORKSPACES_PRIMARY   = { 1, 3, 5, 7, 9 }
local WORKSPACES_SECONDARY = { 2, 4, 6, 8, 10 }

if profile then
    -- Si la secundaria esta desconectada, todo va a la principal: una regla
    -- apuntando a un monitor ausente deja el workspace a la deriva.
    local secondary_up = is_connected(profile.secondary.output)

    for _, workspace in ipairs(WORKSPACES_PRIMARY) do
        hl.workspace_rule({ workspace = workspace, monitor = profile.primary.output })
    end

    for _, workspace in ipairs(WORKSPACES_SECONDARY) do
        local target = secondary_up and profile.secondary.output or profile.primary.output
        hl.workspace_rule({ workspace = workspace, monitor = target })
    end
end
