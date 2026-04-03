{ config, pkgs, ...}:
{
  services.radarr = {
    enable = true;
    openFirewall = true;
    user = "decypharr";
    group = "decypharr";
  };

  services.caddy.virtualHosts."http://radarr.home".extraConfig = ''
    reverse_proxy 127.0.0.1:7878
  '';
}
