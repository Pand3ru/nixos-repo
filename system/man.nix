{ config, pkgs, systemSettings, userSettings, ... }:

{
  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix
  ];

  documentation = {
    dev.enable = true;
    man.generateCaches = true;
    nixos.includeAllModules = true;
  };
}
