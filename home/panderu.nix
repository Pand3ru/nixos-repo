{ config, lib, pkgs, ...}:
{
  imports = [
	./base.nix
	./zsh.nix
	./i3.nix
	./theming.nix
	./i3status.nix
	./nvim.nix
    ./firefox.nix
    ./git.nix
    ./mpv.nix
  ];
  home = {
    packages = with pkgs; [];

    username = "panderu";
    homeDirectory = "/home/panderu";

    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;


  # Disable XFCE4 power management to not interfere with tlp
  xdg.configFile."autostart/xfce4-power-manager.desktop".text = ''
    [Desktop Entry]
    Hidden=true
  '';
}
