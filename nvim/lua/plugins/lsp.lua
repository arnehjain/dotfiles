return {
    {
        "williamboman/mason.nvim",
        opts = {},
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        opts = {
            ensure_installed = { "pyright", "ts_ls", "lua_ls" },
            automatic_installation = true,
        },
        config = function(_, opts)
            require("mason-lspconfig").setup(opts)

            local lspconfig = require("lspconfig")

            -- Capabilities enhanced by nvim-cmp
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            lspconfig.pyright.setup({ capabilities = capabilities })
            lspconfig.ts_ls.setup({ capabilities = capabilities })
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace = { checkThirdParty = false },
                    },
                },
            })
        end,
    },
}
