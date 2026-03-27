{ config, lib, pkgs, userSettings, systemSettings, ... }:
{
  services.resolved.enable = true;
  hardware.bluetooth.enable = true;

  networking.hosts = {
    "192.168.50.203" = [ "desk.home" ];
  };

}
