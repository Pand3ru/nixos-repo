{ config, pkgs, ...}:
{
  services.lidarr = {
    enable = true;
    openFirewall = true;
  };

  services.caddy.virtualHosts."http://lidarr.home".extraConfig = ''
    reverse_proxy 127.0.0.1:8686
  '';
}
