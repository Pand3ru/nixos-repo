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
