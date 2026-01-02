{ config, lib, pkgs, ...}:
{
  imports = [
	./base.nix
	./zsh.nix
	./i3.nix
	./theming.nix
	./kdeconnect.nix
  ];
  home = {
    packages = with pkgs; [
	make
    ];

    username = "panderu";
    homeDirectory = "/home/panderu";

    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
