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
    rev = "885ebdb";
    sha256 = "sha256-3xVRHfGn0171vejFX6UVAPrW82zXDVXAUcshUkS2cNo=";
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
