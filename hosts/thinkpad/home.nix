{ config, pkgs, userSettings, ...}:
{
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
    ../../home/vscode.nix
    ../../home/mimes.nix
    ../../home/xdg.nix
  ];

  home.username = userSettings.username;
  home.homeDirectory = "/home/"+userSettings.username;

  nixpkgs.config.allowUnfree = true;
  programs.home-manager.enable = true;

  home.stateVersion = "25.11";
}
