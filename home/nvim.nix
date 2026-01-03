{ config, pkgs, lib, ...}:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  home.file.".config/nvim".source = pkgs.fetchFromGithub {
    owner = "Pand3ru";
    repo = "nvim-config";
    rev = "61025ed";
    sha265 = lib.fakeHash;
  };

  # Deps
  home.packages = with pkgs; [
    git
    ripgrep
    fd
    lua-language-server
  ];
}
