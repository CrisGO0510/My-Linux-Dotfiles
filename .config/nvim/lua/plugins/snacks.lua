return {
  {
    "folke/snacks.nvim",
    opts = {
      pickers = {
        explorer = {
          hidden = true,             -- Mostrar archivos ocultos
          respect_gitignore = false, -- Ignorar .gitignore para ver más archivos
        },
      },
    },
  }
}
