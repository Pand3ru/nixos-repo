{ config, pkgs, userSettings, ...}:
{
  imports = [
	../../home/nvim.nix
    ../../home/git.nix
    ../../home/ssh.nix
  ];

  home.username = userSettings.username;
  home.homeDirectory = "/home/"+userSettings.username;

  programs.home-manager.enable = true;

  home.stateVersion = "25.11";
}
