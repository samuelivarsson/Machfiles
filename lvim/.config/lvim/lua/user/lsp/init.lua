-- require "user.lsp.languages.go"
-- require "user.lsp.languages.js-ts"
require "user.lsp.languages.python"
require "user.lsp.languages.rust"
require "user.lsp.languages.sh"

-- lvim.lsp.diagnostics.virtual_text = false

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
    "java",
    "python",
}

vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "jdtls" })

-- local formatters = require "lvim.lsp.null-ls.formatters"
-- formatters.setup {
--     { command = "google_java_format", filetypes = { "java" } },
--     { command = "stylua", filetypes = { "lua" } },
--     { command = "shfmt", filetypes = { "sh", "zsh" } },
-- }

-- lvim.lsp.on_attach_callback = function(client, bufnr)
-- end

-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup {
--   { command = "eslint_d", filetypes = { "javascript" } },
-- }

-- _G.lsp_progress = function()
--     if #vim.lsp.get_active_clients() == 0 then
--         return ""
--     end

--     local lsp = vim.lsp.util.get_progress_messages()[1]
--     if lsp then
--         local name = lsp.name or ""
--         local msg = lsp.message or ""
--         local percentage = lsp.percentage or 0
--         local title = lsp.title or ""
--         return string.format(" %%<%s: %s %s (%s%%%%) ", name, title, msg, percentage)
--     end
--     return ""
-- end

-- vim.opt.statusline = [[%{%v:lua.lsp_progress()%}]]
