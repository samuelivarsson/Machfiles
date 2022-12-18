local config = lvim.builtin.dap.ui.config
config.layouts = {
	{
		elements = {
			{ id = "repl", size = 0.3 },
			-- { id = "console", size = 0.59 },
			{ id = "scopes", size = 0.25 },
			{ id = "breakpoints", size = 0.15 },
			{ id = "stacks", size = 0.15 },
			{ id = "watches", size = 0.15 },
		},
		size = 0.20,
		position = "left",
	},
	{
		elements = {
			{ id = "console", size = 1 },
		},
		size = 0.30,
		position = "right",
	},
}
config.floating = {
	max_height = 0.9,
	max_width = 0.5, -- Floats will be treated as percentage of your screen.
	border = vim.g.border_chars, -- Border style. Can be 'single', 'double' or 'rounded'
	mappings = {
		close = { "q", "<Esc>" },
	},
}

lvim.builtin.dap.ui.config = config
lvim.builtin.dap.ui.auto_open = true
-- vim.notify("HEEEEJ", "INFO")
local dap = require("dap")
dap.defaults.fallback.external_terminal = {
	command = "kitty",
	args = { "-e" },
}
-- TODO Make this work
-- lvim.builtin.dap["on_config_done"] = function()
-- 	vim.notify("Hjsa!", "INFO")
-- 	vim.notify(vim.inspect(dap.defaults.fallback.terminal_win_cmd))
-- 	dap.defaults.fallback.terminal_win_cmd = "50vsplit new"
-- 	vim.notify(vim.inspect(dap.defaults.fallback.terminal_win_cmd))
-- end
-- vim.notify("Hejsan!", "INFO")
-- print("Halloooo")
-- dap.defaults.fallback.terminal_win_cmd = "50vsplit new"
dap.defaults.fallback.focus_terminal = true
