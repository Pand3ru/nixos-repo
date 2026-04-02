{ config, pkgs, ...}:
{
  services.whisparr = {
    enable = true;
    openFirewall = true;
  };
}
