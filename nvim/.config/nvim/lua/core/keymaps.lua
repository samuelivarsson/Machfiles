local opts = { noremap = true, silent = true }
local keymap = vim.keymap.set

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

keymap("v", "p", '"_dP', opts)
-- keymap("v", "p", 'mode() ==# "V" ? \'"_dP\' : \'"_dP\'', { noremap = true, silent = true, expr = true })

if vim.g.vscode then
    vim.cmd [[source $HOME/.config/nvim/vscode/settings.vim]]
else
    -- let space be leader
    vim.g.mapleader = " "

    keymap("n", "<Leader>e", "<cmd>NvimTreeToggle<CR>", opts)

    -- Better window navigation
    keymap("n", "<C-h>", "<C-W>h", opts)
    keymap("n", "<C-j>", "<C-W>j", opts)
    keymap("n", "<C-k>", "<C-W>k", opts)
    keymap("n", "<C-l>", "<C-W>l", opts)

    -- Save with ctrl+s
    keymap("n", "<C-s>", ":w<CR>", opts)
    keymap("i", "<C-s>", "<esc>:w<CR>", opts)
    keymap("x", "<C-s>", "<esc>:w<CR>", opts)

    -- Clear highlighting
    keymap("n", "<Leader>h", "<cmd>nohl<CR>", opts)

    -- Quit
    keymap("n", "<Leader>q", "<cmd>q<CR>", opts)
    keymap("n", "<Leader>Q", "<cmd>qall<CR>", opts)
end

local hop = require('hop')
local directions = require('hop.hint').HintDirection
vim.keymap.set('', 'f', function()
    hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = false })
end, { remap = true })
vim.keymap.set('', 'F', function()
    hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = false })
end, { remap = true })
vim.keymap.set('', 't', function()
    hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = false, hint_offset = -1 })
end, { remap = true })
vim.keymap.set('', 'T', function()
    hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = false, hint_offset = 1 })
end, { remap = true })
