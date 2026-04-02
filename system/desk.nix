{ config, pkgs, userSettings, ... }:
{
  services.caddy.virtualHosts."http://desk.home".extraConfig = ''
    root * ${userSettings.installationPath}/assets/desk.html
    file_server
  '';
}
