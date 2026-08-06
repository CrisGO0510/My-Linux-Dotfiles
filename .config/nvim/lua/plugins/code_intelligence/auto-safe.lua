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
          conform.format({ async = false, lsp_format = "fallback", timeout_ms = 2000 })
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
			-- El pre_save formatea síncrono: con un debounce corto el freeze cae
			-- en medio de una ráfaga de tipeo. 3500ms lo saca de esa ventana.
			debounce_delay = 3500,

    },
  },
}
