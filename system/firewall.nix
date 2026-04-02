{ config, pkgs, lib, ... }:
{
  networking.firewall = {
    enable = true;
    allowPing = false;
  };
}
