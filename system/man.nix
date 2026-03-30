{ config, pkgs, systemSettings, userSettings, ... }:

{
  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix
    gawk
  ];

  documentation = {
    dev.enable = true;
    man.generateCaches = true;
    nixos.includeAllModules = true;
  };
}
