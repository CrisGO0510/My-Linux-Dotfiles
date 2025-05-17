return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
  },
  build = ":MasonUpdate",
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { "lua_ls", "rust_analyzer", "jdtls" },
      automatic_installation = true,
    })

    -- Configuración directa de LSP
    local lspconfig = require("lspconfig")
    local servers = { "lua_ls", "rust_analyzer", "jdtls" }
    for _, server in ipairs(servers) do
      lspconfig[server].setup({})
    end
  end,
}
