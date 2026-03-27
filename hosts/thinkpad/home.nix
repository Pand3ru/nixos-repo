{ config, pkgs, userSettings, ...}:
{
  # TODO: fix pathing
  imports = [
	../../home/base.nix
	../../home/zsh.nix
	../../home/theming.nix
	../../home/nvim.nix
    ../../home/firefox/firefox.nix
    ../../home/git.nix
    ../../home/dconf/settings.nix
    ../../home/ssh.nix
    ../../home/zellij.nix
    ../../home/thunderbird.nix
  ];

  home.username = userSettings.name;
  home.homeDirectory = "/home/"+userSettings.name;

  nixpkgs.config.allowUnfree = true;
  programs.home-manager.enable = true;

  home.stateVersion = "25.11";
}
