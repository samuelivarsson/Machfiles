vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.tabstop = 4
vim.opt.smarttab = true
vim.opt.softtabstop = 4
vim.opt.encoding = 'UTF-8'

-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- let space be leader
vim.g.mapleader = " "

local opts = { noremap = true, silent = true }
local keymap = vim.keymap.set

keymap("n", "<Leader>e", "<cmd>NvimTreeToggle<CR>", opts)
keymap("n", "<C-Space>", "<cmd>echo hej<CR>", opts)

local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    -- My plugins here
    use {
        'nvim-tree/nvim-tree.lua',
        requires = {
            'nvim-tree/nvim-web-devicons', -- optional, for file icons
        },
        -- tag = 'nightly' -- optional, updated every week. (see issue #1193)
        config = function()
            require("nvim-tree").setup({
                view = {
                    width = 30,
                    hide_root_folder = false,
                    side = "left",
                    mappings = {
                        custom_only = false,
                        list = {
                            { key = { "l", "<CR>", "o" }, action = "edit", mode = "n" },
                            { key = "h", action = "close_node" },
                            { key = "v", action = "vsplit" },
                            { key = "C", action = "cd" },
                        },
                    },
                    number = false,
                    relativenumber = false,
                    signcolumn = "yes",
                },
            })
        end
    }
    use {
        "kylechui/nvim-surround",
        tag = "*", -- Use for stability; omit to use `main` branch for the latest features
        config = function()
            require("nvim-surround").setup({
                keymaps = { -- vim-surround style keymaps
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
        end
    }
    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }
    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require('packer').sync()
    end
end)
