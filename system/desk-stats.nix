{ config, lib, pkgs, ... }:
let
  # Statistics for the standing desks (see desk.nix): Prometheus recording rules on top of the
  # `desk` scrape job plus a provisioned Grafana dashboard. Panels 1-4 are embedded on the desk
  # page via /d-solo/desk/desk?panelId=<id>, so their ids must stay fixed.
  prom = { type = "prometheus"; uid = "prometheus"; };
  sel = ''{desk="$desk"}'';

  accent = "#ff8c42";
  sitColor = "#7a808c";

  # ---------------------------------------------------------------- recording rules
  # interval 1m: every recorded sample stands for exactly one minute, so sum_over_time = minutes
  working = "and on (desk) (max by (desk) (desk_working) == 1)";
  rules = {
    groups = [
      {
        name = "desk";
        interval = "1m";
        rules = [
          {
            # Midpoint between the sitting (1) and standing (2) preset, 985 mm if one is missing
            # or they make no sense
            record = "desk:stand_threshold_mm";
            expr = ''
              (
                (max by (desk) (desk_profile_mm{id="1"}) + max by (desk) (desk_profile_mm{id="2"})) / 2
                and on (desk) (max by (desk) (desk_profile_mm{id="2"}) - max by (desk) (desk_profile_mm{id="1"}) > 50)
              )
              or on (desk) (max by (desk) (desk_height_mm) * 0 + 985)
            '';
          }
          {
            # 1 standing / 0 sitting, only while a work day is running (no sample otherwise):
            # sum_over_time = standing minutes, count_over_time = work minutes
            record = "desk:standing_working";
            expr = "(max by (desk) (desk_height_mm) > bool on (desk) desk:stand_threshold_mm) ${working}";
          }
          {
            record = "desk:height_working_mm";
            expr = "max by (desk) (desk_height_mm) ${working}";
          }
          {
            # Vertical distance moved in the last minute, from consecutive 15 s scrapes
            # (catches a full up-and-down within one minute, unlike a plain 1m offset)
            record = "desk:travel_mm";
            expr = "sum by (desk) (sum_over_time(abs(desk_height_mm - desk_height_mm offset 15s)[1m:15s]))";
          }
          {
            record = "desk:auto_working";
            expr = "max by (desk) (desk_auto_enabled) ${working}";
          }
          {
            record = "desk:locked_working";
            expr = "max by (desk) (desk_locked) ${working}";
          }
        ];
      }
    ];
  };

  # ---------------------------------------------------------------- dashboard helpers
  target = { refId ? "A", expr, legendFormat ? "__auto", instant ? false }: {
    inherit refId expr legendFormat instant;
    datasource = prom;
    range = !instant;
  };

  panel = { id, title, type, x, y, w, h, targets, ... }@p:
    { datasource = prom; gridPos = { inherit x y w h; }; }
    // removeAttrs p [ "x" "y" "w" "h" ];

  stat = { unit, expr, color ? "text", decimals ? null, ... }@p:
    panel (removeAttrs p [ "unit" "expr" "color" "decimals" ] // {
      type = "stat";
      targets = [ (target { inherit expr; instant = true; }) ];
      fieldConfig.defaults = {
        inherit unit;
        color = { mode = "fixed"; fixedColor = color; };
        noValue = "–";
      } // lib.optionalAttrs (decimals != null) { inherit decimals; };
      options = {
        colorMode = "value";
        graphMode = "none";
        textMode = "value";
        justifyMode = "center";
        reduceOptions = { calcs = [ "lastNotNull" ]; fields = ""; values = false; };
      };
    });

  # "Today" tiles ignore the dashboard range
  today = p: stat (p // { timeFrom = "now/d"; hideTimeOverride = true; h = 4; w = 4; });
  ranged = p: stat (p // { h = 4; w = 4; });

  # Business Charts panel: lib.js + one panel file become the getOption function
  echarts = { file, ... }@p:
    panel (removeAttrs p [ "file" ] // {
      type = "volkovlabs-echarts-panel";
      pluginVersion = "7.2.4";
      options = {
        editorMode = "code";
        getOption = builtins.readFile ./desk-stats/lib.js + "\n" + builtins.readFile file;
        renderer = "canvas";
        map = "none";
        themeEditor = { name = "default"; config = "{}"; };
        editor.format = "auto";
        visualEditor = { dataset = [ ]; series = [ ]; code = ""; };
        baidu = { key = ""; callback = "bmapReady"; };
        gaode = { key = ""; plugin = "AMap.Scale,AMap.ToolBar"; };
        google = { key = ""; callback = "gmapReady"; };
      };
    });

  # Standing (A) and work (B) minutes per query step; the JS buckets them by local day/hour
  standWork = [
    (target { refId = "A"; expr = "sum(sum_over_time(desk:standing_working${sel}[$__interval]))"; legendFormat = "standing"; })
    (target { refId = "B"; expr = "sum(count_over_time(desk:standing_working${sel}[$__interval]))"; legendFormat = "work"; })
  ];

  timeseries = { unit, targets, overrides ? [ ], custom ? { }, ... }@p:
    panel (removeAttrs p [ "unit" "overrides" "custom" ] // {
      type = "timeseries";
      fieldConfig = {
        defaults = {
          inherit unit;
          color = { mode = "fixed"; fixedColor = accent; };
          custom = { fillOpacity = 10; showPoints = "never"; lineWidth = 1; insertNulls = 180000; } // custom;
        };
        inherit overrides;
      };
      options = { legend.showLegend = false; tooltip.mode = "single"; };
    });

  # ---------------------------------------------------------------- dashboard
  dashboard = {
    uid = "desk";
    title = "Desk";
    tags = [ "desk" ];
    timezone = "browser";
    schemaVersion = 39;
    refresh = "1m";
    time = { from = "now-7d"; to = "now"; };
    graphTooltip = 0;

    templating.list = [
      {
        name = "desk";
        label = "Desk";
        type = "query";
        datasource = prom;
        query = "label_values(desk_height_mm, desk)";
        definition = "label_values(desk_height_mm, desk)";
        refresh = 2;
        sort = 1;
        multi = false;
        includeAll = false;
      }
      {
        name = "goal";
        label = "Daily standing goal (min)";
        type = "custom";
        query = "30,60,90,120";
        current = { text = "60"; value = "60"; };
        options = map (v: { text = v; value = v; selected = v == "60"; }) [ "30" "60" "90" "120" ];
      }
    ];

    panels = [
      # --- today
      (today { id = 10; title = "Standing today"; x = 0; y = 0; unit = "m"; color = accent; decimals = 0;
        expr = "sum_over_time(desk:standing_working${sel}[$__range])"; })
      (today { id = 11; title = "Sitting today"; x = 4; y = 0; unit = "m"; decimals = 0;
        expr = "count_over_time(desk:standing_working${sel}[$__range]) - sum_over_time(desk:standing_working${sel}[$__range])"; })
      (today { id = 12; title = "Standing share today"; x = 8; y = 0; unit = "percentunit"; color = accent; decimals = 0;
        expr = "avg_over_time(desk:standing_working${sel}[$__range])"; })
      (today { id = 13; title = "Posture switches today"; x = 12; y = 0; unit = "none"; decimals = 0;
        expr = "changes(desk:standing_working${sel}[$__range])"; })
      (today { id = 14; title = "Moved today"; x = 16; y = 0; unit = "lengthm"; decimals = 1;
        expr = "sum_over_time(desk:travel_mm${sel}[$__range]) / 1000"; })
      (stat { id = 15; title = "Height now"; x = 20; y = 0; w = 4; h = 4; unit = "lengthmm"; decimals = 0;
        expr = "max(desk_height_mm${sel})"; })

      # --- embedded panels
      (panel {
        id = 1;
        title = "Today";
        description = "Posture over the current day. Grey: sitting, orange: standing (above the midpoint of the two presets), faint: desk on but no work day running.";
        type = "state-timeline";
        x = 0; y = 4; w = 24; h = 5;
        timeFrom = "now/d";
        hideTimeOverride = true;
        interval = "1m";
        maxDataPoints = 1440;
        targets = [
          (target {
            expr = "max by (desk) (desk:standing_working${sel}) or on (desk) (max by (desk) (desk_height_mm${sel}) * 0 - 1)";
            legendFormat = "Posture";
          })
        ];
        fieldConfig.defaults = {
          color.mode = "thresholds";
          thresholds = { mode = "absolute"; steps = [ { color = sitColor; value = null; } ]; };
          mappings = [
            {
              type = "value";
              options = {
                "1" = { text = "Standing"; color = accent; index = 0; };
                "0" = { text = "Sitting"; color = sitColor; index = 1; };
                "-1" = { text = "No work day"; color = "rgba(128, 128, 128, 0.18)"; index = 2; };
              };
            }
          ];
          custom = { fillOpacity = 90; lineWidth = 0; insertNulls = 180000; };
        };
        options = {
          showValue = "never";
          mergeValues = true;
          alignValue = "left";
          rowHeight = 0.85;
          legend = { showLegend = true; displayMode = "list"; placement = "bottom"; };
          tooltip.mode = "single";
        };
      })
      (echarts {
        id = 2;
        title = "Standing calendar";
        description = "Standing minutes per day over the last year (work days only). Full orange = daily goal reached.";
        file = ./desk-stats/calendar.js;
        x = 0; y = 9; w = 12; h = 8;
        timeFrom = "365d";
        hideTimeOverride = true;
        interval = "1h";
        maxDataPoints = 10000;
        targets = standWork;
      })
      (echarts {
        id = 4;
        title = "Last 30 days";
        description = "Standing vs. sitting time per work day; dashed line = daily standing goal.";
        file = ./desk-stats/last30.js;
        x = 12; y = 9; w = 12; h = 8;
        timeFrom = "30d";
        hideTimeOverride = true;
        interval = "1h";
        maxDataPoints = 10000;
        targets = standWork;
      })
      (echarts {
        id = 3;
        title = "Height by hour";
        description = "Time spent at each height (20 mm bands) per hour of the day, during work days in the selected range.";
        file = ./desk-stats/heightByHour.js;
        x = 0; y = 17; w = 12; h = 9;
        interval = "1m";
        maxDataPoints = 10000;
        targets = [ (target { expr = "desk:height_working_mm${sel}"; legendFormat = "height"; }) ];
      })

      # --- selected range
      (timeseries {
        id = 20;
        title = "Height";
        x = 12; y = 17; w = 12; h = 9;
        unit = "lengthmm";
        targets = [
          (target { refId = "A"; expr = "max(desk_height_mm${sel})"; legendFormat = "height"; })
          (target { refId = "B"; expr = "max(desk:stand_threshold_mm${sel})"; legendFormat = "stand threshold"; })
        ];
        custom.lineInterpolation = "stepAfter";
        overrides = [
          {
            matcher = { id = "byName"; options = "stand threshold"; };
            properties = [
              { id = "color"; value = { mode = "fixed"; fixedColor = sitColor; }; }
              { id = "custom.lineStyle"; value = { fill = "dash"; dash = [ 6 4 ]; }; }
              { id = "custom.fillOpacity"; value = 0; }
            ];
          }
        ];
      })
      (ranged { id = 21; title = "Standing in range"; x = 0; y = 26; unit = "m"; color = accent; decimals = 0;
        expr = "sum_over_time(desk:standing_working${sel}[$__range])"; })
      (ranged { id = 22; title = "Work time in range"; x = 4; y = 26; unit = "m"; decimals = 0;
        expr = "count_over_time(desk:standing_working${sel}[$__range])"; })
      (ranged { id = 23; title = "Standing share"; x = 8; y = 26; unit = "percentunit"; color = accent; decimals = 0;
        expr = "avg_over_time(desk:standing_working${sel}[$__range])"; })
      (ranged { id = 24; title = "Height moved"; x = 12; y = 26; unit = "lengthm"; decimals = 1;
        expr = "sum_over_time(desk:travel_mm${sel}[$__range]) / 1000"; })
      (ranged { id = 25; title = "Auto-switch on"; description = "Share of work time with automatic sit/stand switching enabled."; x = 16; y = 26; unit = "percentunit"; decimals = 0;
        expr = "avg_over_time(desk:auto_working${sel}[$__range])"; })
      (ranged { id = 26; title = "Locked"; description = "Share of work time the desk was locked."; x = 20; y = 26; unit = "percentunit"; decimals = 0;
        expr = "avg_over_time(desk:locked_working${sel}[$__range])"; })
      (timeseries {
        id = 27;
        title = "Standing per hour";
        x = 0; y = 30; w = 12; h = 7;
        unit = "m";
        interval = "1h";
        targets = [ (target { expr = "sum(sum_over_time(desk:standing_working${sel}[$__interval]))"; legendFormat = "standing"; }) ];
        custom = { drawStyle = "bars"; fillOpacity = 80; insertNulls = false; };
      })
      (timeseries {
        id = 28;
        title = "Height moved per hour";
        x = 12; y = 30; w = 12; h = 7;
        unit = "lengthm";
        interval = "1h";
        targets = [ (target { expr = "sum(sum_over_time(desk:travel_mm${sel}[$__interval])) / 1000"; legendFormat = "moved"; }) ];
        custom = { drawStyle = "bars"; fillOpacity = 80; insertNulls = false; };
      })

      # --- device health
      {
        id = 30;
        type = "row";
        title = "Device";
        collapsed = false;
        gridPos = { x = 0; y = 37; w = 24; h = 1; };
        panels = [ ];
      }
      (timeseries {
        id = 31;
        title = "WiFi signal";
        x = 0; y = 38; w = 12; h = 7;
        unit = "dBm";
        targets = [ (target { expr = "max(desk_wifi_rssi_dbm${sel})"; legendFormat = "RSSI"; }) ];
        custom.fillOpacity = 0;
      })
      (stat { id = 32; title = "Availability"; description = "Share of successful scrapes in the selected range (desks switched off at night count as down)."; x = 12; y = 38; w = 4; h = 7; unit = "percentunit"; decimals = 1;
        expr = ''avg_over_time(up{job="desk", desk="$desk"}[$__range])''; })
      (stat { id = 33; title = "Restarts"; description = "Uptime counter resets in the selected range (reboots and power cycles)."; x = 16; y = 38; w = 4; h = 7; unit = "none"; decimals = 0;
        expr = "sum(resets(desk_uptime_seconds${sel}[$__range]))"; })
      (stat { id = 34; title = "Uptime"; x = 20; y = 38; w = 4; h = 7; unit = "s"; decimals = 1;
        expr = "max(desk_uptime_seconds${sel})"; })
    ];
  };
in
{
  services.grafana.declarativePlugins = with pkgs.grafanaPlugins; [ volkovlabs-echarts-panel ];

  # Own rule file instead of `rules`, which is concatenated with other modules' strings
  services.prometheus.ruleFiles = [ (pkgs.writeText "desk-rules.yml" (builtins.toJSON rules)) ];

  services.grafana.provision.dashboards.settings.providers = [
    { name = "desk"; options.path = pkgs.writeTextDir "desk.json" (builtins.toJSON dashboard); }
  ];
}
