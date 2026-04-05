return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- load before other plugins
    opts = {
        flavour = "mocha",
    },
    config = function(_, opts)
        require("catppuccin").setup(opts)
        vim.cmd.colorscheme("catppuccin")
    end,
}
