vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrap = false

-- lua/config/options.lua

-- Opciones de interfaz que fallaban
vim.opt.list = true
vim.opt.listchars = { 
  tab = "» ",    -- Muestra los tabs con una flecha sutil
  trail = "·",   -- Muestra espacios al final de la línea
  nbsp = "␣",    -- Muestra espacios inseparables
  extends = "»", 
  precedes = "«" 
}

-- Deshabilitar netrw (explorador de archivos integrado)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Otras opciones para un look "Premium"
vim.opt.cursorline = true         -- Resalta la línea actual
vim.opt.showmode = false          -- No mostrar -- INSERT -- (lualine ya lo hace)
vim.opt.fillchars = { eob = " " } -- Limpia las tildes (~) del final del archivo
vim.opt.pumheight = 10            -- Menú de autocompletado más compacto
vim.opt.scrolloff = 8             -- Mantiene 8 líneas de margen al hacer scroll
