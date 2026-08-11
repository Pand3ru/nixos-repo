local opts = {
    noremap = true,
    silent = true,
}

local k = vim.keymap.set

---------
-- normal
---------

-- nav
k('n', 'J', '<C-D>', opts)
k('n', 'K', '<C-U>', opts)
k('n', 'U', '<C-R>', opts)

k('n', '<Right>', ':tabn<CR>', opts)
k('n', '<Left>', ':tabp<CR>', opts)

k('n', '<C-F>', function()
  local builtin = require('telescope.builtin')
  local ok = pcall(builtin.git_files)
  if not ok then
    builtin.find_files()
  end
end, opts)

k('n', '<C-SPACE>', function() require('telescope.builtin').oldfiles() end, opts)

k('n', '<C-k>', vim.lsp.buf.hover, opts)

k('n', 'gd', function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients > 0 then
    vim.lsp.buf.definition()
  else
    vim.cmd('normal! gf')
  end
end, opts)

k('n', 'gi', vim.lsp.buf.implementation, opts)

k('n', 'gb', '<C-o>', opts)

---------
-- insert
---------

k('i', 'kj', '<ESC>', opts)

---------
-- visual
---------
