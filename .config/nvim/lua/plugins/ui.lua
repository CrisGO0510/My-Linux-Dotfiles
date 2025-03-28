return {

  -- Configurar Lualine
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, {
        function()
          return "😄"
        end,
      })
    end,
  },

  -- Opción alternativa para sobrescribir configuración de Lualine
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      return {
        -- Configuración personalizada aquí
      }
    end,
  },

  -- Deshabilitar bufferline
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },

  -- Usar mini.starter en lugar de alpha
  {
    import = "lazyvim.plugins.extras.ui.mini-starter",

    enabled = false,
  },

}
