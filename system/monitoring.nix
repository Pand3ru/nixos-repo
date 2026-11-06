{ config, lib, pkgs, ... }:
let
  grafanaPort = 3000;
  lanInterface = "enp0s31f6";

  # Dashboards from grafana.com, pinned by revision
  nodeExporterFull = pkgs.fetchurl {
    url = "https://grafana.com/api/dashboards/1860/revisions/45/download";
    hash = "sha256-GExrdAnzBtp1Ul13cvcZRbEM6iOtFrXXjEaY6g6lGYY=";
  };

  # Uses an import-time ${DS_PROMETHEUS} input, which file provisioning doesn't resolve
  smartctlDashboard = pkgs.runCommand "smartctl-dashboard.json" { } ''
    sed 's/''${DS_PROMETHEUS}/prometheus/g' ${pkgs.fetchurl {
      url = "https://grafana.com/api/dashboards/22604/revisions/4/download";
      hash = "sha256-ah36BdFIcaprUz39hRzuYVzfp3diEBckmalMaOls5kY=";
    }} > $out
  '';

  dashboards = pkgs.linkFarm "grafana-dashboards" [
    { name = "node-exporter-full.json"; path = nodeExporterFull; }
    { name = "smartctl.json"; path = smartctlDashboard; }
  ];

  # Every expr only returns series that are in a bad state, so "no data" means healthy.
  # The query maps each match to 1, otherwise `up == 0` would return 0 and never cross the threshold.
  mkRule = { uid, title, expr, for ? "5m", summary }: {
    inherit uid title for;
    condition = "B";
    data = [
      {
        refId = "A";
        datasourceUid = "prometheus";
        relativeTimeRange = { from = 600; to = 0; };
        model = { refId = "A"; expr = "(${expr}) * 0 + 1"; instant = true; };
      }
      {
        refId = "B";
        datasourceUid = "__expr__";
        model = {
          refId = "B";
          type = "threshold";
          expression = "A";
          conditions = [ { evaluator = { type = "gt"; params = [ 0 ]; }; } ];
        };
      }
    ];
    noDataState = "OK";
    execErrState = "Error";
    annotations.summary = summary;
  };

  alertRules = [
    (mkRule {
      uid = "smart-failed";
      title = "SMART status failed";
      expr = "smartctl_device_smart_status == 0";
      for = "0m";
      summary = "SMART meldet Fehler für {{ $labels.device }}";
    })
    (mkRule {
      uid = "smart-sectors";
      title = "Bad sectors increasing";
      expr = ''delta(smartctl_device_attribute{attribute_name=~"Reallocated_Sector_Ct|Current_Pending_Sector|Offline_Uncorrectable",attribute_value_type="raw"}[1d]) > 0'';
      for = "0m";
      summary = "{{ $labels.attribute_name }} steigt auf {{ $labels.device }}";
    })
    (mkRule {
      uid = "nvme-errors";
      title = "NVMe errors";
      expr = "smartctl_device_critical_warning > 0 or delta(smartctl_device_media_errors[1d]) > 0";
      for = "0m";
      summary = "NVMe-Warnung oder Media Errors auf {{ $labels.device }}";
    })
    (mkRule {
      uid = "disk-temp";
      title = "Disk too hot";
      expr = ''smartctl_device_temperature{temperature_type="current"} > 55'';
      for = "15m";
      summary = "{{ $labels.device }} ist über 55 °C warm";
    })
    (mkRule {
      uid = "fs-full";
      title = "Filesystem almost full";
      expr = ''node_filesystem_avail_bytes{mountpoint=~"/|/mnt/.+",fstype!~"tmpfs|ramfs"} / node_filesystem_size_bytes < 0.10'';
      for = "30m";
      summary = "{{ $labels.mountpoint }} ist über 90 % voll";
    })
    (mkRule {
      uid = "unit-failed";
      title = "Systemd unit failed";
      expr = ''node_systemd_unit_state{state="failed"} == 1'';
      for = "0m";
      summary = "{{ $labels.name }} ist fehlgeschlagen";
    })
    (mkRule {
      uid = "exporter-down";
      title = "Exporter down";
      # Desks are switched off at night
      expr = ''up{job!="desk"} == 0'';
      summary = "{{ $labels.job }} ist nicht erreichbar";
    })
  ];
in
{
  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    retentionTime = "2y";

    exporters = {
      node = {
        enable = true;
        listenAddress = "127.0.0.1";
        enabledCollectors = [ "systemd" ];
      };
      # Explicit by-id paths: USB disks can swap sdX names between boots and the scan picks
      # /dev/nvme0 (root-only) instead of the namespace.
      # The WD Elements (1058:267f) is left out: its USB bridge passes no SMART data at all,
      # not even with -d scsi (no status, temperature 0).
      smartctl = {
        enable = true;
        listenAddress = "127.0.0.1";
        devices = [
          "/dev/disk/by-id/nvme-SAMSUNG_MZVLB512HAJQ-000L7_S3TNNX0M429362;nvme"
          "/dev/disk/by-id/ata-TOSHIBA_MQ04ABF100_Y7I7P95OT;sat"
        ];
      };
    };

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [ { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ]; } ];
      }
      {
        job_name = "smartctl";
        static_configs = [ { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}" ]; } ];
      }
    ];
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = grafanaPort;
        domain = "grafana.panderu.org";
        root_url = "https://grafana.panderu.org/";
      };
      # All four values come from the grafana agenix env file
      security = {
        admin_user = "admin";
        admin_password = "$__env{GF_ADMIN_PASSWORD}";
        secret_key = "$__env{GF_SECRET_KEY}";
        allow_embedding = true;
      };
      # grafana.home (LAN/VPN only) logs in automatically as a viewer so the desk page can embed
      # panels; Caddy sets the header there and strips it on grafana.panderu.org, which still needs a login
      "auth.proxy" = {
        enabled = true;
        header_name = "X-WEBAUTH-USER";
        header_property = "username";
        auto_sign_up = true;
        whitelist = "127.0.0.1, ::1";
      };
      users.auto_assign_org_role = "Viewer";
      analytics.reporting_enabled = false;
    };

    provision = {
      enable = true;

      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            uid = "prometheus";
            url = "http://127.0.0.1:${toString config.services.prometheus.port}";
            isDefault = true;
          }
        ];
      };

      dashboards.settings = {
        apiVersion = 1;
        providers = [ { name = "homelab"; options.path = dashboards; } ];
      };

      alerting = {
        contactPoints.settings = {
          apiVersion = 1;
          contactPoints = [
            {
              orgId = 1;
              name = "pushover";
              receivers = [
                {
                  uid = "pushover";
                  type = "pushover";
                  settings = {
                    userKey = "$PUSHOVER_USER_KEY";
                    apiToken = "$PUSHOVER_APP_TOKEN";
                  };
                }
              ];
            }
          ];
        };

        policies.settings = {
          apiVersion = 1;
          policies = [
            {
              orgId = 1;
              receiver = "pushover";
              group_by = [ "alertname" ];
              repeat_interval = "12h";
            }
          ];
        };

        rules.settings = {
          apiVersion = 1;
          groups = [
            {
              orgId = 1;
              name = "homelab";
              folder = "Alerts";
              interval = "1m";
              rules = alertRules;
            }
          ];
        };
      };
    };
  };

  systemd.services.grafana.serviceConfig.EnvironmentFile = config.age.secrets.grafana.path;

  # Only reachable from LAN and wireguard (iPhone: http://10.0.0.1:3000)
  networking.firewall.interfaces = {
    ${lanInterface}.allowedTCPPorts = [ grafanaPort ];
    wg0.allowedTCPPorts = [ grafanaPort ];
  };

  services.caddy.virtualHosts."grafana.panderu.org" = {
    bookmark = "Grafana";
    # Strip the auth proxy header: Caddy connects from the whitelisted 127.0.0.1
    extraConfig = ''
      reverse_proxy 127.0.0.1:${toString grafanaPort} {
        header_up -X-WEBAUTH-USER
      }
    '';
  };

  # Port 80 is open to the internet, a spoofed Host header must not get the auto login
  services.caddy.virtualHosts."http://grafana.home".extraConfig = ''
    @external not remote_ip private_ranges
    abort @external

    reverse_proxy 127.0.0.1:${toString grafanaPort} {
      header_up X-WEBAUTH-USER desk-viewer
    }
  '';

  # Dead man's switch: healthchecks.io alerts via pushover when these pings stop
  systemd.timers.hc-heartbeat = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "*:0/5";
  };

  systemd.services.hc-heartbeat = {
    description = "Heartbeat ping to healthchecks.io";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = config.age.secrets.healthchecks.path;
      ExecStart = "${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 -o /dev/null \${HC_HEARTBEAT_URL}";
    };
  };
}
