return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    dashboard = {
        sections = {
          {
            section = "terminal",
            cmd = "chafa ~/.config/nvim/img/crab-icon.png --format symbols --symbols braille --size $(tput cols)x$(tput lines); sleep .1",
            -- cmd = "kitten icat --place 60x17@0x0 ~/.config/nvim/img/crab-icon.png",
            height = 17,
            padding = 1,
          },
          {
            pane = 2,
            { section = "keys", gap = 1, padding = 1 },
            { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
            { section = "startup" },          },
        },
    },
    explorer = { enabled = false },
    indent = { enabled = true },
    input = { enabled = true },
    picker = { enabled = false },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
}
