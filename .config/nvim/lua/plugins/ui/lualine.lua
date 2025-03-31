return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  config = function()
    require("lualine").setup({
      options = {
        theme = "auto",
        section_separators = "",
        component_separators = "",
        disabled_filetypes = {
          statusline = { "lazy", "neo-tree" }, -- Asegurar que no se desactiva en ciertos buffers
          winbar = {},
        },
        ignore_focus = { "toggleterm", "lazyterm" }, -- Evita que se desactive en terminales
      },
    })
  end,
}
