{ config, pkgs, ...}:
{
  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  services.caddy.virtualHosts."http://sonarr.home".extraConfig = ''
    reverse_proxy 127.0.0.1:8989
  '';
}
