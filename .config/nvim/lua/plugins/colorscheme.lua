return {
  -- Agregar gruvbox
  { "ellisonleao/gruvbox.nvim" },
  { "liuchengxu/space-vim-dark" },

  -- Configurar LazyVim para usar gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "space-vim-dark",
    },
  },
}
