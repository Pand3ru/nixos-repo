{ config, pkgs, ... }:
{
  services.caddy.virtualHosts."git.panderu.org".bookmark = "Git";
  services.caddy.virtualHosts."git.panderu.org".extraConfig = ''
    reverse_proxy 127.0.0.1:3010
  '';

  # The module doesn't put the CLI on PATH; needed for creating accounts:
  # sudo -u forgejo forgejo --work-path /var/lib/forgejo admin user create ...
  environment.systemPackages = [ config.services.forgejo.package ];

  services.forgejo = {
    enable = true;

    # Postgres over the local socket; the module creates the database and
    # user, so no password is involved.
    database.type = "postgres";

    # Includes the repositories and a SQL dump of the database. A fixed,
    # uncompressed file gets overwritten daily and dedups well in restic.
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
        # 3000 is Grafana
        HTTP_PORT = 3010;
        DISABLE_SSH = true;
      };

      # Accounts are created by hand: forgejo admin user create
      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;

      # TeXlyre (texlyre.nix) talks to the API straight from the browser
      # to back projects up into a repo.
      cors = {
        ENABLED = true;
        ALLOW_DOMAIN = "texlyre.panderu.org";
        HEADERS = "Content-Type,User-Agent,Authorization";
      };
    };
  };
}
