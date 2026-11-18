{ config, pkgs, ... }:
{
  services.caddy.virtualHosts."git.panderu.org".extraConfig = ''
    reverse_proxy 127.0.0.1:3010
  '';

  environment.systemPackages = [ config.services.forgejo.package ];

  services.forgejo = {
    enable = true;
    database.type = "postgres";

    dump = {
      enable = true;
      type = "tar";
      file = "forgejo-dump";
    };

    settings = {
      server = {
        DOMAIN = "git.panderu.org";
        ROOT_URL = "https://git.panderu.org/";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = 3010; # 3000 is Grafana
        DISABLE_SSH = true;
      };

      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;
    };
  };
}
