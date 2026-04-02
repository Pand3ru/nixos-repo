{ config, pkgs, systemSettings, userSettings, lib, ... }:
{
  networking = rec {
    hostName = "homelab";
    domain = "panderu.org";

    networkmanager.enable = true;

    nat = {
      enable = true;
      externalInterface = "enp0s31f6";
      internalInterfaces = [ "wg0" ];
    };
  };
}
