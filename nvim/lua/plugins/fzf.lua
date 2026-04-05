return {
  "ibhagwan/fzf-lua",
  -- optional for icon support
  dependencies = { "nvim-tree/nvim-web-devicons" },
  ---@module "fzf-lua"
  ---@type fzf-lua.Config|{}
  ---@diagnostic disable: missing-fields
  opts = {},
  ---@diagnostic enable: missing-fields
  keys = {
    { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Fzf files generic" },
    { "<leader>fg", "<cmd>FzfLua git_files<cr>", desc = "Fzf git files" },
    {
      "<leader>fo",
      function()
        local current_dir = vim.fn.expand("%:p:h")
        require("fzf-lua").files({ cwd = current_dir })
      end,
      desc = "Files (cwd only)",
    },
  },
}
