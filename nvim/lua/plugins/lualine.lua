return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        require('lualine').setup({
            options = {
                theme = "catppuccin",
                icons_enabled = true,
            }
        })
        vim.opt.showmode = false
    end,
}
