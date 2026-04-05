return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
        ensure_installed = {
            "python", "typescript", "javascript",
            "lua", "json", "yaml", "bash", "markdown", "go",
        },
        highlight = { enable = true },
        indent = { enable = true },
    },
    config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
    end,
}
