-- vimtex
vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_compiler_latexmk = {
  continuous = 1,
  out_dir = "build",
  options = {
    "-pdf",
    "-interaction=nonstopmode",
    "-synctex=1",
  },
}
vim.g.vimtex_quickfix_mode = 0

-- telescope
require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["kj"] = "close",
        ["<CR>"] = "select_tab",
      },
    },
  },
})

-- completion
require("blink.cmp").setup({
  keymap = {
    preset = "enter",
    ["<Up>"] = { "select_prev", "fallback" },
    ["<Down>"] = { "select_next", "fallback" },
    ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
  },
  appearance = {
    nerd_font_variant = "mono",
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    per_filetype = {
      tex = { "buffer", "path", "snippets" },
    },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
  completion = {
    keyword = { range = "prefix" },
    menu = {
      draw = {
        treesitter = { "lsp" },
      },
    },
    trigger = { show_on_trigger_character = true },
    documentation = {
      auto_show = true,
    },
  },
  signature = { enabled = true },
})

-- treesitter highlighting (starts wherever a parser is installed, no-ops otherwise)
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

-- lsp
vim.lsp.enable({ "gopls", "rust_analyzer" })

-- format on save
require("conform").setup({
  formatters_by_ft = {
    go = { "goimports", "gofmt" },
    rust = { "rustfmt" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
