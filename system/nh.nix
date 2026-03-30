{ config, pkgs, systemSettings, userSettings, ... }:
{
  programs.nh = {
    enable = true;
    flake = userSettings.installationPath;
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 5d --keep 3";
    };
  };
}
