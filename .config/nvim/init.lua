-- init.lua

-- 1. Definir la Leader key ANTES que nada
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 2. Cargar opciones básicas (independientes de plugins)
require("config.options")

-- 3. Cargar el gestor de plugins (Lazy)
require("config.lazy")

-- 4. Cargar configuraciones que dependen de plugins o que sobreescriben mapeos
require("config.keymaps")
require("config.autocmds")
