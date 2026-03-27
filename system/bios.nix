{ config, pkgs, systemSettings, userSettings, ... }:

{
    # https://nixos.wiki/wiki/Fwupd
    services.fwupd.enable = true;
}
