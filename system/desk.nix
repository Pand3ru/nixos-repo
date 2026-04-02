{ config, pkgs, userSettings, ... }:
{
  services.nginx.virtualHosts."desk.home" = {
    listen = [
      { addr = "127.0.0.1"; port = 80; }
      { addr = "192.168.50.203"; port = 80; }
    ];
    root = "${userSettings.installationPath}/assets/desk.html";
  };
}
