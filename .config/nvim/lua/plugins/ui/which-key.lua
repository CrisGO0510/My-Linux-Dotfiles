return {
  "folke/which-key.nvim",
  lazy = false, -- config/keymaps.lua lo requiere al arrancar: todos los mapeos pasan por wk.add
  config = function()
    require("which-key").setup()
  end,
}
