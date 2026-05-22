-- (Sin notificación de autosave: cmdline ruidoso con cada guardado)

return {
  {
    "okuuva/auto-save.nvim",
    cmd = "ASToggle",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      enabled = true,
      trigger_events = {
        immediate_save = { nil },
				defer_save = { "InsertLeave", "TextChanged" },
        cancel_deferred_save = { "InsertEnter" },
      },
      pre_save = function()
        local ok, conform = pcall(require, "conform")
        if ok then
          conform.format({ async = false, lsp_fallback = true, timeout_ms = 2000 })
        end
      end,
      condition = function(buf)
        if vim.bo[buf].filetype == "harpoon" then
          return false
        end
        local fn = vim.fn
        local utils = require("auto-save.utils.data")
        if utils.not_in(fn.getbufvar(buf, "&filetype"), { "mysql" }) then
          return true
        end
        return false
      end,
      write_all_buffers = false,
			noautocmd = true,
      lockmarks = false,
			debounce_delay = 2000,

    },
  },
}
