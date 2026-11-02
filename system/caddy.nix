{ config, lib, pkgs, ... }:
let
  logDir = config.services.caddy.logDir;
in
{
  # Extends every vhost, from any module: JSON access log that alloy can read (group caddy),
  # kept for a month, plus an optional Firefox bookmark name (read by home/firefox/bookmarks.nix)
  options.services.caddy.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({ config, ... }: {
      options.bookmark = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Bookmark name on the thinkpad, null for no bookmark.";
      };

      config.logFormat = lib.mkDefault ''
        output file ${logDir}/access-${lib.replaceStrings [ "/" " " ] [ "_" "_" ] config.hostName}.log {
          mode 0640
          roll_keep_for 720h
        }
        format json
      '';
    }));
  };

  config = {
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    services.caddy = {
      enable = true;
      email = "acme@pankratov.de";
    };

    systemd.services.caddy.serviceConfig = {
      ProtectHome = lib.mkForce "read-only";
    };
  };
}
