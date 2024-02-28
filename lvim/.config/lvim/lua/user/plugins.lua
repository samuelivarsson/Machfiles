-- Additional Plugins
lvim.plugins = {
  -- Extra options in folder
  "MattesGroeger/vim-bookmarks",
  "kevinhwang91/nvim-bqf",
  "NvChad/nvim-colorizer.lua",
  "ghillb/cybu.nvim",
  "j-hui/fidget.nvim",
  "f-person/git-blame.nvim",
  "ruifm/gitlinker.nvim",
  "christianchiarulli/harpoon",
  "lvimuser/lsp-inlayhints.nvim",
  "is0n/jaq-nvim",
  "ggandor/leap.nvim",
  "TimUntersberger/neogit",
  "nacro90/numb.nvim",
  "petertriho/nvim-scrollbar",
  "opalmay/vim-smoothie",
  "windwp/nvim-spectre",
  "kylechui/nvim-surround",
  "folke/todo-comments.nvim",
  "folke/zen-mode.nvim",

  -- No extra options
  "moll/vim-bbye",
  "hrsh7th/cmp-emoji",
  "leoluz/nvim-dap-go",
  "mfussenegger/nvim-dap-python",
  "mxsdev/nvim-dap-vscode-js",
  "sindrets/diffview.nvim",
  "mattn/vim-gist",
  "mfussenegger/nvim-jdtls",
  "nvim-treesitter/playground",
  "simrat39/rust-tools.nvim",
  "nvim-treesitter/nvim-treesitter-textobjects",
  "windwp/nvim-ts-autotag",
  -- "christianchiarulli/nvim-ts-rainbow",
  "mattn/webapi-vim",
  -- "olexsmir/gopher.nvim",
  -- "jose-elias-alvarez/typescript.nvim",

  -- Color schemes
  "lunarvim/darkplus.nvim",
  "lunarvim/templeos.nvim",

  -- Options in file
  {
    "saecki/crates.nvim",
    version = "v0.3.0",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup({
        null_ls = {
          enabled = true,
          name = "crates.nvim",
        },
      })
    end,
  },
  {
    "jinh0/eyeliner.nvim",
    config = function()
      require("eyeliner").setup({
        highlight_on_key = true,
      })
    end,
  },
  { "christianchiarulli/telescope-tabs",      branch = "chris" },
  { "tom-anders/telescope-vim-bookmarks.nvim" },
  { "nvim-telescope/telescope-dap.nvim" },
  {
    "tzachar/cmp-tabnine",
    event = "InsertEnter",
    build = "./install.sh",
  },
  {
    "zbirenbaum/copilot.lua",
    -- cmd = "Copilot",
    event = "InsertEnter",
  },
  {
    "zbirenbaum/copilot-cmp",
    after = { "copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },
  {
    "folke/trouble.nvim",
    config = function()
      require("trouble").setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      })
    end,
  },
  {
    "folke/noice.nvim",
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
  },
  {
    "phaazon/hop.nvim",
    branch = "v2", -- optional but strongly recommended
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      local hop = require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })
      -- local directions = require("hop.hint").HintDirection
      -- vim.keymap.set("", "f", function()
      -- 	hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
      -- end, { remap = true })
      -- vim.keymap.set("", "F", function()
      -- 	hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
      -- end, { remap = true })
      -- vim.keymap.set("", "t", function()
      -- 	hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
      -- end, { remap = true })
      -- vim.keymap.set("", "T", function()
      -- 	hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
      -- end, { remap = true })
    end,
  },
  -- https://github.com/jose-elias-alvarez/typescript.nvim
  -- "rmagatti/auto-session",
  -- "rmagatti/session-lens"
}
