return {
  {
    "echasnovski/mini.starter",
    version = "*",
    opts = function(_, opts)
      opts = opts or {} -- Ensure opts is a table
      opts.items = opts.items or {
        { name = "New File",     action = "enew",               section = "Files" },
        { name = "Recent Files", action = "Telescope oldfiles", section = "Files" },
        { name = "Quit",         action = "qa",                 section = "Session" },
      }
      return opts
    end,
  }
}
