{ config, lib, pkgs, ...}:
{
  imports = [
	./base.nix
	./zsh.nix
	./theming.nix
	./nvim.nix
    ./firefox.nix
    ./git.nix
    ./mpv.nix
    ./gnome.nix
  ];
  home = {
    packages = with pkgs; [];

    username = "panderu";
    homeDirectory = "/home/panderu";

    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;
}
