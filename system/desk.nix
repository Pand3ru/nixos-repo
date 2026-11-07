{ config, lib, pkgs, ... }:
let
  cfg = config.desk;

  site = pkgs.linkFarm "desk-site" [
    { name = "index.html"; path = ../assets/desk/index.html; }
    {
      name = "desks.json";
      path = pkgs.writeText "desks.json" (builtins.toJSON (map (d: { inherit (d) host ip; }) cfg.desks));
    }
  ];

  # The ESP32 serves its API on port 80; the server can't resolve the ESP hostnames,
  # so both the host route and the IP fallback route go to the static IP
  proxy = ip: ''
    reverse_proxy ${ip}:80 {
      transport http {
        dial_timeout 2s
        response_header_timeout 8s
      }
    }
  '';

  deskRoutes = lib.concatMapStrings (d: ''
    handle_path /api/${d.host}/* {
      ${proxy d.ip}
    }
    handle_path /api/ip/${d.ip}/* {
      ${proxy d.ip}
    }
  '') cfg.desks;
in
{
  options.desk.desks = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        host = lib.mkOption {
          type = lib.types.str;
          description = "Desk hostname, used in /api/<host>/ and as the Prometheus `desk` label.";
        };
        ip = lib.mkOption {
          type = lib.types.str;
          description = "Static LAN IP of the desk's ESP32.";
        };
      };
    });
    default = [
      { host = "Mausi1Tisch"; ip = "192.168.50.120"; }
      { host = "Mausi2Tisch"; ip = "192.168.50.94"; }
    ];
    description = "Standing desk controllers proxied under http://desk.home/api/ and scraped by Prometheus.";
  };

  config = {
    # /api/ip/<ip>/ is the IP fallback route, a desk called "ip" would shadow it
    assertions = [
      {
        assertion = lib.all (d: lib.toLower d.host != "ip") cfg.desks;
        message = "desk.desks: \"ip\" is reserved as a host name (/api/ip/<ip>/ route).";
      }
    ];

    services.caddy.virtualHosts."http://desk.home".bookmark = "Desk";
    # Also reachable by the server IP for devices that don't use dnsmasq
    services.caddy.virtualHosts."http://desk.home".serverAliases = [ "http://192.168.50.203" ];
    # Port 80 is open to the internet for ACME, so a spoofed Host header must not reach the desks.
    # Everything sits in one route to keep the written order: Caddy sorts abort after handle otherwise.
    # The frontend falls back to /api/ip/<ip>/ only on network errors or 502/504, hence the 502.
    services.caddy.virtualHosts."http://desk.home".extraConfig = ''
      @external not remote_ip private_ranges
      # The frontend polls /status, keep it out of the access log
      @poll path /api/*/status /api/ip/*/status

      route {
        abort @external
        log_skip @poll

        ${deskRoutes}
        handle /api/* {
          respond "unknown desk" 502
        }

        handle {
          root * ${site}
          file_server
        }
      }
    '';

    services.prometheus.scrapeConfigs = [
      {
        job_name = "desk";
        metrics_path = "/metrics";
        scrape_interval = "15s";
        scrape_timeout = "5s";
        static_configs = map (d: {
          targets = [ "${d.ip}:80" ];
          labels.desk = d.host;
        }) cfg.desks;
      }
    ];
  };
}
