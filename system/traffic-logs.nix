{ config, lib, pkgs, ... }:
let
  lokiPort = 3100;
  lokiDir = config.services.loki.dataDir;
  caddyLogs = config.services.caddy.logDir;

  # Dashboard: no hostname anywhere, everything comes from the instance/host label values,
  # so new vhosts (or a second machine shipping to this Loki) show up on their own.
  loki = { type = "loki"; uid = "loki"; };
  sel = extra: ''{job="caddy", instance=~"$instance", host=~"$host", origin=~"$origin"${extra}}'';
  all = sel "";

  range = expr: legendFormat: { refId = "A"; datasource = loki; queryType = "range"; inherit expr legendFormat; };
  instant = expr: { refId = "A"; datasource = loki; queryType = "instant"; inherit expr; };

  panel = { id, title, type, x, y, w, h, targets, ... }@p:
    { datasource = loki; gridPos = { inherit x y w h; }; }
    // removeAttrs p [ "x" "y" "w" "h" ];

  stat = { unit, expr, ... }@p: panel (removeAttrs p [ "unit" "expr" ] // {
    type = "stat";
    h = 4;
    w = 6;
    targets = [ (instant expr) ];
    fieldConfig.defaults = { inherit unit; color.mode = "fixed"; color.fixedColor = "text"; };
    options = { colorMode = "none"; graphMode = "none"; reduceOptions.calcs = [ "lastNotNull" ]; };
  });

  graph = { unit, expr, legend, stack ? false, overrides ? [ ], ... }@p:
    panel (removeAttrs p [ "unit" "expr" "legend" "stack" "overrides" ] // {
      type = "timeseries";
      targets = [ (range expr legend) ];
      fieldConfig = {
        defaults = {
          inherit unit;
          custom = { fillOpacity = 15; showPoints = "never"; stacking.mode = if stack then "normal" else "none"; };
        };
        inherit overrides;
      };
      options.legend = { displayMode = "table"; placement = "right"; calcs = [ "sum" "max" ]; };
    });

  # Instant vector → one row per label combination, sorted by request count
  table = { expr, columns, ... }@p: panel (removeAttrs p [ "expr" "columns" ] // {
    type = "table";
    targets = [ (instant expr) ];
    transformations = [
      { id = "labelsToFields"; options.mode = "columns"; }
      { id = "merge"; options = { }; }
      { id = "organize"; options = { excludeByName.Time = true; renameByName = columns // { Value = "Requests"; }; }; }
      { id = "sortBy"; options.sort = [ { field = "Requests"; desc = true; } ]; }
    ];
    fieldConfig.overrides = [
      {
        matcher = { id = "byName"; options = "Requests"; };
        properties = [ { id = "custom.cellOptions"; value = { type = "gauge"; mode = "basic"; }; } ];
      }
    ];
  });

  variable = name: query: {
    inherit name query;
    label = name;
    definition = query;
    type = "query";
    datasource = loki;
    refresh = 2;
    sort = 1;
    multi = true;
    includeAll = true;
    allValue = ".+";
    current = { text = [ "All" ]; value = [ "$__all" ]; };
  };

  # Collapsed row below the last panel (ends at y = 58), data from system/fail2ban.nix.
  # Exporter metrics have no per-IP labels; the IP list comes from the fail2ban SQLite db and Loki.
  prometheus = { type = "prometheus"; uid = "prometheus"; };
  fail2banDb = { type = "frser-sqlite-datasource"; uid = "fail2ban-db"; };

  f2bStat = { id, title, x, w, expr, legendFormat ? "", description ? "" }: {
    inherit id title description;
    type = "stat";
    datasource = prometheus;
    gridPos = { inherit x w; y = 59; h = 4; };
    targets = [ { refId = "A"; datasource = prometheus; instant = true; inherit expr legendFormat; } ];
    fieldConfig.defaults = { unit = "short"; color.mode = "fixed"; color.fixedColor = "text"; };
    options = { colorMode = "none"; graphMode = "none"; textMode = "value_and_name"; reduceOptions.calcs = [ "lastNotNull" ]; };
  };

  # bips holds one row per (ip, jail), the latest ban; it's what fail2ban restores on start
  # and what unbanip deletes from. bantime -1 = permanent.
  activeBansSql = ''
    SELECT timeofban AS time, ip, jail,
           json_extract(data, '$.failures') AS failures,
           bancount
    FROM bips
    WHERE bantime = -1 OR timeofban + bantime > CAST(strftime('%s', 'now') AS INTEGER)
    ORDER BY timeofban DESC
  '';

  fail2banRow = [
    {
      id = 14; type = "row"; title = "fail2ban"; collapsed = true;
      gridPos = { x = 0; y = 58; w = 24; h = 1; };
      panels = [
        (f2bStat { id = 15; title = "Aktuell gebannt pro Jail"; x = 0; w = 12;
          expr = "sum by (jail) (f2b_jail_banned_current)"; legendFormat = "{{jail}}"; })
        (f2bStat { id = 16; title = "Aktuell gebannt"; x = 12; w = 6;
          expr = "sum(f2b_jail_banned_current)"; })
        (f2bStat { id = 17; title = "Bans gesamt"; x = 18; w = 6;
          description = "Summe von f2b_jail_banned_total; fail2ban zählt ab dem letzten Start (wiederhergestellte Bans eingeschlossen).";
          expr = "sum(f2b_jail_banned_total)"; })

        {
          id = 18; type = "table"; title = "Aktive Bans (vollständig, unabhängig vom Zeitraum)";
          description = "Direkt aus der fail2ban-Datenbank (Tabelle bips), neueste zuerst. Entsperrte IPs verschwinden hier sofort.";
          datasource = fail2banDb;
          gridPos = { x = 0; y = 63; w = 24; h = 12; };
          targets = [ { refId = "A"; datasource = fail2banDb; queryType = "table"; rawQueryText = activeBansSql; queryText = activeBansSql; timeColumns = [ "time" ]; } ];
          transformations = [
            { id = "organize"; options.renameByName = { time = "Gebannt seit"; ip = "IP"; jail = "Jail"; failures = "Treffer"; bancount = "Bans"; }; }
          ];
          options.sortBy = [ { displayName = "Gebannt seit"; desc = true; } ];
        }

        {
          id = 19; type = "table"; title = "Ban-Ereignisse im gewählten Zeitraum (Loki)";
          description = "Ban-/Unban-Zeilen aus dem fail2ban-Log, nur innerhalb des Dashboard-Zeitraums. Die vollständige Liste steht in der Tabelle darüber.";
          datasource = loki;
          gridPos = { x = 0; y = 75; w = 24; h = 10; };
          targets = [ (range ''{job="fail2ban", instance=~"$instance"}'' "") ];
          transformations = [
            { id = "extractFields"; options = { source = "labels"; format = "json"; replace = false; }; }
            {
              id = "organize";
              options = {
                includeByName = { Time = true; action = true; jail = true; ip = true; };
                indexByName = { Time = 0; action = 1; jail = 2; ip = 3; };
                renameByName = { Time = "Zeit"; action = "Aktion"; jail = "Jail"; ip = "IP"; };
              };
            }
          ];
          options.sortBy = [ { displayName = "Zeit"; desc = true; } ];
        }
      ];
    }
  ];

  dashboard = {
    uid = "caddy-traffic";
    title = "Caddy Traffic";
    tags = [ "caddy" "loki" ];
    timezone = "browser";
    schemaVersion = 39;
    # Every refresh is ~15 requests through caddy itself, so keep it slow
    refresh = "5m";
    time = { from = "now-24h"; to = "now"; };

    templating.list = [
      (variable "instance" ''label_values({job="caddy"}, instance)'')
      (variable "host" ''label_values({job="caddy", instance=~"$instance"}, host)'')
      {
        name = "origin";
        label = "origin";
        type = "custom";
        query = "external,internal";
        includeAll = true;
        allValue = ".+";
        current = { text = "external"; value = "external"; };
        options = map (v: { text = v; value = v; selected = v == "external"; }) [ "external" "internal" ];
      }
    ];

    panels = [
      (stat { id = 1; title = "Requests"; x = 0; y = 0; unit = "short";
        expr = "sum(count_over_time(${all}[$__range]))"; })
      (stat { id = 2; title = "Client-IPs"; x = 6; y = 0; unit = "short";
        expr = "count(sum by (ip) (count_over_time(${all}[$__range])))"; })
      (stat { id = 3; title = "Fehlerquote (5xx)"; x = 12; y = 0; unit = "percentunit";
        expr = ''(sum(count_over_time(${sel '', status=~"5.."'' }[$__range])) or vector(0)) / sum(count_over_time(${all}[$__range]))''; })
      (stat { id = 4; title = "Ausgeliefert"; x = 18; y = 0; unit = "bytes";
        expr = ''sum(sum_over_time(${all} | json size="size" | __error__="" | unwrap size [$__range]))''; })

      (panel {
        id = 5; title = "Herkunft der Requests"; type = "geomap"; x = 0; y = 4; w = 16; h = 13;
        targets = [ (instant ''sum by (geoip_location_latitude, geoip_location_longitude, geoip_city_name, geoip_country_name) (count_over_time(${all} | geoip_country_code != "" [$__range]))'') ];
        transformations = [
          { id = "labelsToFields"; options.mode = "columns"; }
          { id = "merge"; options = { }; }
          {
            id = "convertFieldType";
            options.conversions = [
              { targetField = "geoip_location_latitude"; destinationType = "number"; }
              { targetField = "geoip_location_longitude"; destinationType = "number"; }
            ];
          }
        ];
        fieldConfig.defaults.color.mode = "continuous-YlRd";
        options = {
          view = { id = "coords"; lat = 30; lon = 10; zoom = 1.6; };
          controls = { showZoom = true; mouseWheelZoom = true; };
          basemap = { type = "default"; name = "Basemap"; };
          tooltip.mode = "details";
          layers = [
            {
              type = "markers";
              name = "Requests";
              tooltip = true;
              location = { mode = "coords"; latitude = "geoip_location_latitude"; longitude = "geoip_location_longitude"; };
              config = {
                showLegend = true;
                style = {
                  size = { field = "Value"; min = 4; max = 30; fixed = 5; };
                  color.field = "Value";
                  opacity = 0.6;
                  symbol = { mode = "fixed"; fixed = "img/icons/marker/circle.svg"; };
                };
              };
            }
          ];
        };
      })
      (table { id = 6; title = "Top-Länder"; x = 16; y = 4; w = 8; h = 13;
        columns.geoip_country_name = "Land";
        expr = ''topk(20, sum by (geoip_country_name) (count_over_time(${all} | geoip_country_name != "" [$__range])))''; })

      (graph { id = 7; title = "Requests pro Host"; x = 0; y = 17; w = 12; h = 8; unit = "reqps"; legend = "{{host}}";
        expr = "sum by (host) (rate(${all}[$__auto]))"; })
      (graph { id = 8; title = "Statuscodes"; x = 12; y = 17; w = 12; h = 8; unit = "reqps"; legend = "{{status}}"; stack = true;
        expr = "sum by (status) (rate(${all}[$__auto]))";
        overrides = map ({ re, color }: {
          matcher = { id = "byRegexp"; options = re; };
          properties = [ { id = "color"; value = { mode = "fixed"; fixedColor = color; }; } ];
        }) [
          { re = "^2"; color = "green"; }
          { re = "^3"; color = "blue"; }
          { re = "^4"; color = "orange"; }
          { re = "^5"; color = "red"; }
        ]; })

      (graph { id = 9; title = "Traffic pro Host"; x = 0; y = 25; w = 12; h = 8; unit = "Bps"; legend = "{{host}}";
        expr = ''sum by (host) (rate(${all} | json size="size" | __error__="" | unwrap size [$__auto]))''; })
      (graph { id = 10; title = "Antwortzeit p95"; x = 12; y = 25; w = 12; h = 8; unit = "s"; legend = "{{host}}";
        expr = ''quantile_over_time(0.95, ${all} | json duration="duration" | __error__="" | unwrap duration [$__auto]) by (host)''; })

      (table { id = 11; title = "Top-Client-IPs"; x = 0; y = 33; w = 12; h = 11;
        columns = { ip = "IP"; geoip_country_name = "Land"; geoip_city_name = "Stadt"; };
        expr = "topk(25, sum by (ip, geoip_country_name, geoip_city_name) (count_over_time(${all}[$__range])))"; })
      (table { id = 12; title = "Top-Pfade"; x = 12; y = 33; w = 12; h = 11;
        columns = { host = "Host"; method = "Methode"; uri = "Pfad"; };
        expr = ''topk(25, sum by (host, method, uri) (count_over_time(${all} | json method="request.method", uri="request.uri" [$__range])))''; })

      (panel {
        id = 13; title = "Requests"; type = "logs"; x = 0; y = 44; w = 24; h = 14;
        targets = [ (range all "") ];
        options = { showTime = true; wrapLogMessage = false; enableLogDetails = true; sortOrder = "Descending"; };
      })
    ] ++ lib.optionals config.services.fail2ban.enable fail2banRow;
  };
in
{
  # Single-node Loki for the caddy access logs. Not in restic.paths, so it's not backed up.
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      analytics.reporting_enabled = false;

      server = {
        http_listen_address = "127.0.0.1";
        http_listen_port = lokiPort;
        grpc_listen_address = "127.0.0.1";
        grpc_listen_port = 9096;
        log_level = "warn";
      };

      common = {
        path_prefix = lokiDir;
        instance_addr = "127.0.0.1";
        replication_factor = 1;
        ring.kvstore.store = "inmemory";
        storage.filesystem = {
          chunks_directory = "${lokiDir}/chunks";
          rules_directory = "${lokiDir}/rules";
        };
      };

      schema_config.configs = [
        {
          # Must predate every line in the existing caddy logs, otherwise Loki answers 500
          # and alloy stalls retrying those batches. Lines older than a week still get a clean 400.
          from = "2020-01-01";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = { prefix = "index_"; period = "24h"; };
        }
      ];

      limits_config = {
        retention_period = "720h";
        allow_structured_metadata = true;
      };

      compactor = {
        working_directory = "${lokiDir}/compactor";
        retention_enabled = true;
        delete_request_store = "filesystem";
      };
    };
  };

  # Tails the caddy access logs, adds a GeoIP lookup and pushes to Loki.
  # Rotated files (access-<host>-<timestamp>.log) are skipped, they were already read under the live name.
  # Only host and status become labels; IP and geo data go into structured metadata to keep cardinality low.
  # Private IPs (LAN, wireguard) get no country and stay off the map.
  services.alloy.enable = true;

  environment.etc."alloy/config.alloy".text = ''
    logging {
      level = "warn"
    }

    local.file_match "caddy" {
      path_targets = [{
        "__path__"         = "${caddyLogs}/access-*.log",
        "__path_exclude__" = "${caddyLogs}/access-*T[0-9][0-9]-[0-9][0-9]-[0-9][0-9]*.log",
      }]
    }

    loki.source.file "caddy" {
      targets    = local.file_match.caddy.targets
      forward_to = [loki.process.caddy.receiver]
    }

    loki.process "caddy" {
      stage.json {
        expressions = {
          ip     = "request.remote_ip",
          host   = "request.host",
          status = "status",
          ts     = "ts",
        }
      }

      // Some clients send the port in the Host header (grafana.panderu.org:443); one label per vhost
      stage.replace {
        source      = "host"
        expression  = "(:[0-9]+)$"
        replace     = ""
      }

      // origin=internal for LAN, wireguard, loopback and IPv6 ULA/link-local, everything else is external
      stage.regex {
        source     = "ip"
        expression = `^(?P<internal_ip>(?:10|127)\.|192\.168\.|172\.(?:1[6-9]|2[0-9]|3[01])\.|169\.254\.|f[cd][0-9a-f]{2}:|fe80:|::1$)`
      }

      stage.template {
        source   = "origin"
        template = `{{ if .internal_ip }}internal{{ else }}external{{ end }}`
      }

      stage.timestamp {
        source = "ts"
        format = "Unix"
      }

      stage.geoip {
        source  = "ip"
        db      = "${pkgs.dbip-city-lite.mmdb}"
        db_type = "city"
      }

      stage.labels {
        values = {
          host   = "",
          status = "",
          origin = "",
        }
      }

      stage.structured_metadata {
        values = {
          ip                       = "",
          geoip_country_name       = "",
          geoip_country_code       = "",
          geoip_city_name          = "",
          geoip_location_latitude  = "",
          geoip_location_longitude = "",
        }
      }

      stage.static_labels {
        values = {
          job      = "caddy",
          instance = "${config.networking.hostName}",
        }
      }

      stage.label_drop {
        values = ["filename"]
      }

      forward_to = [loki.write.local.receiver]
    }

    loki.write "local" {
      endpoint {
        url = "http://127.0.0.1:${toString lokiPort}/loki/api/v1/push"
      }
    }
  '';

  systemd.services.alloy = {
    wants = [ "loki.service" ];
    after = [ "loki.service" ];
    serviceConfig.SupplementaryGroups = [ "caddy" ];
    restartTriggers = [ config.environment.etc."alloy/config.alloy".source ];
  };

  services.grafana.provision = {
    datasources.settings.datasources = [
      {
        name = "Loki";
        type = "loki";
        uid = "loki";
        url = "http://127.0.0.1:${toString lokiPort}";
      }
    ];

    dashboards.settings.providers = [
      { name = "traffic"; options.path = pkgs.writeTextDir "caddy-traffic.json" (builtins.toJSON dashboard); }
    ];
  };

  # Caddy only applies its log `mode` to new files; fix up logs created before as 0600
  systemd.tmpfiles.rules = [ "z ${caddyLogs}/access-*.log 0640 caddy caddy -" ];
}
