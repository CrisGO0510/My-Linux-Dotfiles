return {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-project.nvim" },
    config = function()
        require("telescope").setup({
            defaults = {
                file_ignore_patterns = { "%.git/" }, -- Opcional, para ignorar la carpeta .git
            },
            pickers = {
                find_files = {
                    find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" }
                },
                live_grep = {
                    additional_args = function()
                        return { "--hidden" }
                    end
                }
            },
            extensions = {
                project = {
                    base_dirs = {
                        "~/Documents/Repo",
                        "~/dotfiles",
                    },
                    hidden_files = true,
                    theme = "dropdown",
                    order_by = "recent"
                }
            }
        })
        require("telescope").load_extension("project")
    end
}
