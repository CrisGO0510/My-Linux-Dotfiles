-- █▀▄▀█ █▀█ █▄░█ █ ▀█▀ █▀█ █▀█ █▀
-- █░▀░█ █▄█ █░▀█ █ ░█░ █▄█ █▀▄ ▄█
--
-- Especifico de la rama `laptop`.

local EXTERNAL = "HDMI-A-1"
local INTERNAL = "eDP-1"

hl.monitor({ output = EXTERNAL, mode = "1920x1080@60", position = "0x0",    scale = 1 })
hl.monitor({ output = INTERNAL, mode = "1920x1080@60", position = "1920x0", scale = 1.5 })


-- ▄▀█ █▀ █ █▀▀ █▄░█ ▄▀█ █▀▀ █ █▀█ █▄░█   █▀▄ █▀▀   █░█░█ █▀
-- █▀█ ▄█ █ █▄█ █░▀█ █▀█ █▄▄ █ █▄█ █░▀█   █▄▀ ██▄   ▀▄▀▄▀ ▄█

-- Pares en la pantalla interna, impares en la externa.
local WORKSPACES_INTERNAL = { 2, 4, 6, 8, 10 }
local WORKSPACES_EXTERNAL = { 1, 3, 5, 7, 9 }

for _, workspace in ipairs(WORKSPACES_INTERNAL) do
    hl.workspace_rule({ workspace = workspace, monitor = INTERNAL })
end

for _, workspace in ipairs(WORKSPACES_EXTERNAL) do
    hl.workspace_rule({ workspace = workspace, monitor = EXTERNAL })
end
