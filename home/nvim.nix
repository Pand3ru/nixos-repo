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
    rev = "4b7e2e8";
    sha256 = "sha256-e9+Mdfq+lcBOQyNpjSCsxVdiylDh7QbVDKcfZDxXQF0=";
    # sha256 = lib.fakeHash;
  };

  # Deps
  home.packages = with pkgs; [
    git
    ripgrep
    fd
    lua-language-server
    xclip
    xsel
  ];
}
