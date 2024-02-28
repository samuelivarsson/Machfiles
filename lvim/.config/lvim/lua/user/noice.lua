local status_ok, noice = pcall(require, "noice")
if not status_ok then
  return
end

noice.setup({
  -- add any options here
  lsp = {
    progress = { enabled = false },
    signature = { enabled = false },
    hover = { enabled = false }
  }
})
