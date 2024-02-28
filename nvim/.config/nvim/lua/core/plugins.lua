local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

local nvimtree = require("core.nvimtree")

local plugins = {
    -- My plugins here
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons", -- optional, for file icons
        },
        cond = function() return vim.g.vscode == nil end,
        -- tag = 'nightly' -- optional, updated every week. (see issue #1193)
        config = function()
            require("nvim-tree").setup({
                view = {
                    width = 30,
                    hide_root_folder = false,
                    side = "left",
                    number = false,
                    relativenumber = false,
                    signcolumn = "yes",
                },
                on_attach = nvimtree.on_attach,
            })
        end,
    },
    {
        "phaazon/hop.nvim",
        branch = "v2",
        config = function()
            -- you can configure Hop the way you like here; see :h hop-config
            require 'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
        end
    },
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({
                keymaps = {
                    -- vim-surround style keymaps
                    insert = "<C-g>s",
                    insert_line = "<C-g>S",
                    normal = "s",
                    normal_cur = "ss",
                    normal_line = "S",
                    normal_cur_line = "SS",
                    visual = "s",
                    visual_line = "gS",
                    delete = "ds",
                    change = "cs",
                },
            })
        end,
    },
    {
        "numToStr/Comment.nvim",
        cond = function() return vim.g.vscode == nil end,
        config = function()
            require("Comment").setup()
        end,
    }
}

local opts = {}

require("lazy").setup(plugins, opts)
