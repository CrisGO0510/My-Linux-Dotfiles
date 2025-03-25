return {
  "glacambre/firenvim",
  build = function()
    vim.fn["firenvim#install"]()
  end,
  config = function()
    vim.g.firenvim_config = {
      globalSettings = { alt = "all" },
      localSettings = {
        [".*"] = {
          cmdline = "neovim",
          priority = 0,
          selector = "textarea",
          takeover = "always",
        },
      },
    }
  end,
}
