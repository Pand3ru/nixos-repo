{ config, pkgs, systemSettings, userSettings, ... }:

{
  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix
    gawk
  ];

  documentation = {
    dev.enable = true;
    man.cache.enable = true;
    nixos.includeAllModules = true;
  };
}
