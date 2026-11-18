{ config, pkgs, ... }:
{
  services.caddy.virtualHosts."vw.panderu.org".extraConfig = ''
    reverse_proxy 127.0.0.1:8222
  '';

  services.vaultwarden = {
    enable = true;
    backupDir = "/var/lib/vaultwarde/backup";

    environmentFile = config.age.secrets.email.path;

    config = {
      DOMAIN = "https://vw.panderu.org/";
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";

      ORGS_ALLOWED = true;
      ORG_EVENTS_DISABLED = true;
    };
  };
}
