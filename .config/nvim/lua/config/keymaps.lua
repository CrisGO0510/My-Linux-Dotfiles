local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("t", "<C-Esc>", "<C-\\><C-n>", opts)
-- map("n", "<leader>E", ":Neotree toggle reveal=true position=left dir=" .. vim.fn.expand("%:p:h") .. "<CR>", opts) -- CWD
-- map("n", "<leader>e", ":Neotree toggle reveal=true position=left dir=" .. vim.fn.getcwd() .. "<CR>", opts)

map("n", "<leader><space>", function()
  require("telescope.builtin").find_files({
    cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1] or vim.fn.getcwd(),
    hidden = true,
  })
end, { desc = "Find Files (Project Root)" })
