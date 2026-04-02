{ config, pkgs, ...}:
{
  services.whisparr = {
    enable = true;
    openFirewall = true;
  };

  services.caddy.virtualHosts."http://whisparr.home".extraConfig = ''
    reverse_proxy 127.0.0.1:6969
  '';
}
