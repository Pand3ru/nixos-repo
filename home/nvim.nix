{ config, pkgs, lib, ...}:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # use lib.fakeHash in order to get hash
  home.file.".config/nvim".source = pkgs.fetchFromGitHub {
    owner = "Pand3ru";
    repo = "nvim-config";
    rev = "61025ed";
    sha256 = "sha256-k5sz7d0ZJi5r1Ap3MVraD8dMm1zda9LlrmX0CgLCsTw=";
  };

  # Deps
  home.packages = with pkgs; [
    git
    ripgrep
    fd
    lua-language-server
  ];
}
