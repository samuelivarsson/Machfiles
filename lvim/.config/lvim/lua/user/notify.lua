local status_ok, notify = pcall(require, "notify")
if not status_ok then
    return
end

vim.notify = notify.setup(
    {
        background_colour = "#000000",
        fps = 30,
        icons = {
            DEBUG = "",
            ERROR = "",
            INFO = "",
            TRACE = "✎",
            WARN = ""
        },
        level = 0,
        minimum_width = 50,
        render = "default",
        stages = "fade_in_slide_out",
        timeout = 5000,
        top_down = true
    }
)
