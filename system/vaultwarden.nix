{ config, pkgs, ... }:
{
  services.nginx.virtualHosts."vw.panderu.org" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8222";
    };
  };

  services.vaultwarden = {
    enable = true;
    backupDir = "/var/lib/vaultwarde/backup";

    config = {
      DOMAIN = "https://vw.panderu.org/";
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";

      ORG_CREATION_USERS = "none";
    };
  };
}
