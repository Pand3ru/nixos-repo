{ config, pkgs, userSettings, ... }:
{
  services.caddy.virtualHosts."http://desk.home".extraConfig = ''
    root * ${userSettings.installationPath}/assets/desk/
    file_server
  '';
}
