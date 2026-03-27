{ config, pkgs, lib, ... }:
{
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # I hate myself for this...
  services.flatpak.enable = true;
}
