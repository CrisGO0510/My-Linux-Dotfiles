return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        find_command = { "rg", "--files", "--hidden", "--no-ignore" },
        cwd = vim.fn.getcwd(), -- Asegura que busque desde la raíz
      },
    },
  },
}
