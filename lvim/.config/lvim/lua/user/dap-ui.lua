local status_ok, dap_ui = pcall(require, "dapui")
if not status_ok then
    return
end

local config = lvim.builtin.dap.ui.config
config.layouts =
{
    {
        elements = {
            -- { id = "repl", size = 0.01 },
            { id = "console", size = 0.59 },
            { id = "scopes", size = 0.1 },
            { id = "breakpoints", size = 0.1 },
            { id = "stacks", size = 0.1 },
            { id = "watches", size = 0.1 },
        },
        size = 0.33,
        position = "right",
    },
    {
        elements = {
            { id = "repl", size = 1 },
        },
        size = 0.01,
        position = "bottom",
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

dap_ui.setup(config)
