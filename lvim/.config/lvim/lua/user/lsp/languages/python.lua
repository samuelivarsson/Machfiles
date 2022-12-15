-- Set a formatter.
local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
	{ command = "black", filetypes = { "python" } },
})

-- Set a linter.
local linters = require("lvim.lsp.null-ls.linters")
linters.setup({
	{
		command = "flake8",
		extra_args = { "--max-line-length", "88", "--extend-ignore", "E203" },
		filetypes = { "python" },
	},
})

-- Setup dap for python
local mason_path = vim.fn.glob(vim.fn.stdpath("data") .. "/mason/")
pcall(function()
	require("dap-python").setup(mason_path .. "packages/debugpy/venv/bin/python")
	-- require("dap-python").setup("python")
end)

-- Supported test frameworks are unittest, pytest and django. By default it
-- tries to detect the runner by probing for pytest.ini and manage.py, if
-- neither are present it defaults to unittest.
pcall(function()
	require("dap-python").test_runner = "pytest"
end)

require("dap-python").resolve_python = function()
	return "/usr/bin/python3"
end

-- table.insert(require('dap').configurations.python, {
--     type = 'python',
--     request = 'launch',
--     name = 'Launch with args',
--     program = '${file}',
--     console = 'integratedTerminal',
--     args = { "" }
--     -- ... more options, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
-- })

vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = { "python" },
	callback = function()
		lvim.builtin.which_key.mappings["dm"] = { "<cmd>lua require('dap-python').test_method()<cr>", "Test Method" }
		lvim.builtin.which_key.mappings["df"] = { "<cmd>lua require('dap-python').test_class()<cr>", "Test Class" }
		lvim.builtin.which_key.vmappings["d"] = {
			name = "Debug",
			s = { "<cmd>lua require('dap-python').debug_selection()<cr>", "Debug Selection" },
		}
	end,
})
