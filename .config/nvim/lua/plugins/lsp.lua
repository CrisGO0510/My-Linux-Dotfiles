return {
  -- Agregar soporte para Pyright
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {},
      },
    },
  },

  -- Agregar soporte para TypeScript con typescript.nvim
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/typescript.nvim",
      init = function()
        require("lazyvim.util").lsp.on_attach(function(_, buffer)
          vim.keymap.set("n", "<leader>co", "TypescriptOrganizeImports",
            { buffer = buffer, desc = "Organize Imports" })
          vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { buffer = buffer, desc = "Rename File" })
        end)
      end,
    },
    opts = {
      servers = {
        tsserver = {},
      },
      setup = {
        tsserver = function(_, opts)
          require("typescript").setup({ server = opts })
          return true
        end,
      },
    },
  },

  -- Importar configuración adicional de TypeScript
  { import = "lazyvim.plugins.extras.lang.typescript" },
}
