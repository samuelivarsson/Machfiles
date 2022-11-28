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
    "ggandor/leap.nvim",
    "nvim-treesitter/playground",
    "simrat39/rust-tools.nvim",
    "nvim-treesitter/nvim-treesitter-textobjects",
    "windwp/nvim-ts-autotag",
    "p00f/nvim-ts-rainbow",
    "mattn/webapi-vim",
    -- "olexsmir/gopher.nvim",
    -- "jose-elias-alvarez/typescript.nvim",

    -- Color schemes
    "lunarvim/darkplus.nvim",
    "lunarvim/templeos.nvim",

    -- Options in file
    {
        "saecki/crates.nvim",
        tag = "v0.3.0",
        requires = { "nvim-lua/plenary.nvim" },
        config = function()
            require("crates").setup {
                null_ls = {
                    enabled = true,
                    name = "crates.nvim",
                },
            }
        end,
    },
    {
        "jinh0/eyeliner.nvim",
        config = function()
            require("eyeliner").setup {
                highlight_on_key = true,
            }
        end,
    },
    { "christianchiarulli/telescope-tabs", branch = "chris" },
    { "tzachar/cmp-tabnine", run = "./install.sh" },
    {
        "zbirenbaum/copilot.lua",
        event = { "VimEnter" },
        config = function()
            vim.defer_fn(function()
                require("copilot").setup {
                    plugin_manager_path = os.getenv "LUNARVIM_RUNTIME_DIR" .. "/site/pack/packer",
                }
            end, 100)
        end,
    },
    {
        "zbirenbaum/copilot-cmp",
        after = { "copilot.lua" },
        config = function()
            require("copilot_cmp").setup {
                formatters = {
                    insert_text = require("copilot_cmp.format").remove_existing,
                },
            }
        end,
    },
    -- "MunifTanjim/nui.nvim",
    -- {
    --   "folke/noice.nvim",
    --   event = "VimEnter",
    --   config = function()
    --     require("noice").setup()
    --   end,
    -- },

    -- https://github.com/jose-elias-alvarez/typescript.nvim
    -- "rmagatti/auto-session",
    -- "rmagatti/session-lens"
}
