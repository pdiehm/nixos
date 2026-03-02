vim.keymap.del("n", "gra")
vim.keymap.del("n", "gri")
vim.keymap.del("n", "grn")
vim.keymap.del("n", "grr")
vim.keymap.del("n", "grt")

for _, key in pairs({ ";", "," }) do
  vim.keymap.set("i", key, function()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]

    if vim.tbl_contains({ "()", "[]", "{}" }, line:sub(col, col + 1)) then
      return "<Esc>la" .. key .. "<Esc>hi"
    else
      return key
    end
  end, { expr = true, noremap = true })
end

vim.lsp.buf.empty_rename = function()
  vim.ui.input({ prompt = "New Name: " }, function(name)
    vim.lsp.buf.rename(name)
  end)
end
