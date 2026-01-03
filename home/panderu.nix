{ config, lib, pkgs, ...}:
{
  imports = [
	./base.nix
	./zsh.nix
	./i3.nix
	./theming.nix
	./i3status.nix
	./nvim.nix
  ];
  home = {
    packages = with pkgs; [];

    username = "panderu";
    homeDirectory = "/home/panderu";

    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
