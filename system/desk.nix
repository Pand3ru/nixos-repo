{ config, pkgs, userSettings, ... }:
{
  services.caddy.virtualHosts."http://desk.home".bookmark = "Desk";
  services.caddy.virtualHosts."http://desk.home".extraConfig = ''
    root * /srv/desk/
    file_server
  '';
}
