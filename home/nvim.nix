{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    initLua = ''
      require("options")
      require("keymaps")
      require("setup")
    '';

    plugins = with pkgs.vimPlugins; [
      vimtex
      plenary-nvim
      telescope-nvim
      friendly-snippets
      blink-cmp
      nvim-lspconfig
      conform-nvim

      (nvim-treesitter.withPlugins (p: [
        p.go
        p.gomod
        p.gosum
        p.rust
        p.lua
        p.vim
        p.vimdoc
        p.query
        p.bash
        p.markdown
        p.markdown_inline
      ]))
    ];
  };

  xdg.configFile."nvim/lua".source = ./nvim/lua;

  # Deps
  home.packages = with pkgs; [
    git
    ripgrep
    fd
    xclip
    xsel

    gopls
    gotools
    go
    rust-analyzer
    rustfmt
    rustc
  ];
}
