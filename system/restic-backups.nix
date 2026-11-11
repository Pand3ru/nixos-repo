{ config, pkgs, lib, ... }:
with lib;
let
  envFiles = [
    config.age.secrets.backup-user.path
    config.age.secrets.backup-host.path
    config.age.secrets.backup-storage-pass.path
    config.age.secrets.backup-restic-pass.path
  ];

  knownHosts = "/var/lib/restic/known_hosts";

  # accept-new pins the storage box host key on first contact without putting the hostname in the repo
  repoArgs = ''-r "sftp:$BACKUP_USER@$BACKUP_HOST:backup/restic" -o sftp.args="-p 23 -i ${config.age.secrets.backup-sk.path} -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=${knownHosts}"'';

  restic-repo = pkgs.writeShellScriptBin "restic-repo" ''
    set -eu
    set -a
    ${concatMapStringsSep "\n" (f: ". ${f}") envFiles}
    set +a
    export RESTIC_CACHE_DIR="''${RESTIC_CACHE_DIR:-/var/cache/restic}"
    exec ${pkgs.restic}/bin/restic ${repoArgs} "$@"
  '';

  # node_exporter reads *.prom files from here, that's how the Backups dashboard gets its numbers
  textfileDir = "/var/lib/prometheus-node-exporter-textfile";
  jq = "${pkgs.jq}/bin/jq";

  # Atomic write, node_exporter must never see a half-written file
  promFn = ''
    prom() { cat > "${textfileDir}/$1.prom.tmp" && mv "${textfileDir}/$1.prom.tmp" "${textfileDir}/$1.prom"; }
  '';

  # Pings healthchecks.io on success and on failure, so a missed or failed run both alert.
  # restic-backup-run.prom is written on every run, restic-backup.prom only on success
  # (so it keeps the numbers of the last good run).
  backupScript = pkgs.writeShellScript "restic-backup" ''
    set -u
    ping() { ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 -o /dev/null "$HC_BACKUP_URL$1" || true; }
    ${promFn}

    out=$(mktemp)
    trap 'rm -f "$out"' EXIT
    start=$(date +%s)
    # Exit code 3: snapshot written, but some files couldn't be read
    ${restic-repo}/bin/restic-repo backup --json ${concatStringsSep " " config.restic.paths} > "$out"
    rc=$?
    ok=0
    if [ "$rc" -eq 0 ] && ${restic-repo}/bin/restic-repo forget --prune --keep-weekly 8 --keep-monthly 12; then
      ok=1
    fi
    end=$(date +%s)

    printf '%s\n' \
      "restic_backup_last_run_timestamp_seconds $end" \
      "restic_backup_exit_code $rc" \
      "restic_backup_success $ok" | prom restic-backup-run

    if [ "$ok" -eq 1 ]; then
      summary=$(${jq} -c 'select(.message_type == "summary")' "$out" | tail -n 1)
      [ -n "$summary" ] || summary='{}'
      stats=$(${restic-repo}/bin/restic-repo stats --mode raw-data --json || echo '{}')
      ${jq} -rn --argjson s "$summary" --argjson r "$stats" --arg end "$end" --arg dur "$((end - start))" '
        [ "restic_backup_last_success_timestamp_seconds \($end)",
          "restic_backup_duration_seconds \($dur)",
          "restic_backup_files_new \($s.files_new // 0)",
          "restic_backup_files_changed \($s.files_changed // 0)",
          "restic_backup_files_unmodified \($s.files_unmodified // 0)",
          "restic_backup_data_added_bytes \($s.data_added // 0)",
          "restic_backup_processed_files \($s.total_files_processed // 0)",
          "restic_backup_processed_bytes \($s.total_bytes_processed // 0)",
          (if $r.total_size then "restic_repo_size_bytes \($r.total_size)" else empty end),
          (if $r.total_uncompressed_size then "restic_repo_uncompressed_bytes \($r.total_uncompressed_size)" else empty end),
          (if $r.snapshots_count then "restic_snapshots_total \($r.snapshots_count)" else empty end)
        ] | .[]' | prom restic-backup
      ping ""
    else
      ping "/fail"
      exit 1
    fi
  '';

  checkScript = pkgs.writeShellScript "restic-check" ''
    set -u
    ${promFn}
    start=$(date +%s)
    ${restic-repo}/bin/restic-repo check --read-data-subset=5%
    rc=$?
    end=$(date +%s)
    printf '%s\n' \
      "restic_check_last_run_timestamp_seconds $end" \
      "restic_check_duration_seconds $((end - start))" \
      "restic_check_success $([ "$rc" -eq 0 ] && echo 1 || echo 0)" | prom restic-check
    exit "$rc"
  '';

  # Static list of what's backed up, for the dashboard
  pathsProm = pkgs.writeText "restic-paths.prom"
    (concatMapStrings (p: ''restic_backup_path_info{path="${p}"} 1'' + "\n") config.restic.paths);

  # ---------------------------------------------------------------- dashboard
  prom = { type = "prometheus"; uid = "prometheus"; };
  day = 86400;

  panel = { id, title, type, x, y, w, h, targets, ... }@p:
    { datasource = prom; gridPos = { inherit x y w h; }; }
    // removeAttrs p [ "x" "y" "w" "h" ];

  target = expr: legendFormat: { refId = "A"; datasource = prom; inherit expr legendFormat; };

  # Single value; mappings turn 0/1 into words, steps colour the value
  stat = { expr, unit ? "none", steps ? [ { color = "text"; value = null; } ], mappings ? [ ], noValue ? "never ran", ... }@p:
    panel (removeAttrs p [ "expr" "unit" "steps" "mappings" "noValue" ] // {
      type = "stat";
      targets = [ ((target expr "") // { instant = true; range = false; }) ];
      fieldConfig.defaults = {
        inherit unit mappings noValue;
        color.mode = "thresholds";
        thresholds = { mode = "absolute"; inherit steps; };
      };
      options = {
        colorMode = "value";
        graphMode = "none";
        textMode = "value";
        reduceOptions = { calcs = [ "lastNotNull" ]; fields = ""; values = false; };
      };
    });

  # Values only change once per run, so draw steps with points instead of a smooth line
  graph = { expr, unit, legend ? "", ... }@p:
    panel (removeAttrs p [ "expr" "unit" "legend" ] // {
      type = "timeseries";
      targets = [ (target expr legend) ];
      fieldConfig.defaults = {
        inherit unit;
        custom = { lineInterpolation = "stepAfter"; fillOpacity = 10; showPoints = "never"; spanNulls = true; };
      };
      options.legend = { displayMode = "list"; placement = "bottom"; };
    });

  okFailed = [
    { type = "value"; options = {
        "1" = { text = "OK"; color = "green"; index = 0; };
        "0" = { text = "Failed"; color = "red"; index = 1; };
      }; }
  ];

  # Weekly backup: fine up to 8 days, late after that, broken after two missed runs
  ageSteps = [ { color = "green"; value = null; } { color = "orange"; value = 8 * day; } { color = "red"; value = 15 * day; } ];

  dashboard = {
    uid = "backups";
    title = "Backups";
    tags = [ "restic" ];
    timezone = "browser";
    schemaVersion = 39;
    refresh = "5m";
    time = { from = "now-1y"; to = "now"; };

    panels = [
      (stat {
        id = 1; title = "Last successful backup"; x = 0; y = 0; w = 6; h = 5;
        expr = "time() - restic_backup_last_success_timestamp_seconds";
        unit = "dtdurations"; steps = ageSteps;
        description = "Weekly timer. Orange after 8 days, red after 15 (two missed runs).";
      })
      (stat {
        id = 2; title = "Last run"; x = 6; y = 0; w = 6; h = 5;
        expr = "restic_backup_success"; mappings = okFailed;
        description = "Failed also covers forget/prune errors. See the exit code below and journalctl -u restic-backup.";
      })
      (stat {
        id = 3; title = "Last check"; x = 12; y = 0; w = 6; h = 5;
        expr = "restic_check_success"; mappings = okFailed;
        description = "Monthly restic check reading back 5% of the data.";
      })
      (stat {
        id = 4; title = "Failed units"; x = 18; y = 0; w = 6; h = 5;
        expr = ''sum(node_systemd_unit_state{name=~"restic-(backup|check)\\.service", state="failed"})'';
        noValue = "–";
        mappings = [ { type = "value"; options = { "0" = { text = "None"; color = "green"; index = 0; }; }; } ];
        steps = [ { color = "green"; value = null; } { color = "red"; value = 1; } ];
      })

      (stat { id = 5; title = "Snapshots"; x = 0; y = 5; w = 4; h = 4; expr = "restic_snapshots_total"; })
      (stat { id = 6; title = "Repository size"; x = 4; y = 5; w = 4; h = 4; expr = "restic_repo_size_bytes"; unit = "bytes"; })
      (stat { id = 7; title = "Backed up data"; x = 8; y = 5; w = 4; h = 4; expr = "restic_backup_processed_bytes"; unit = "bytes";
        description = "Size of all backed up paths in the last run, before dedup and compression."; })
      (stat { id = 8; title = "Added last run"; x = 12; y = 5; w = 4; h = 4; expr = "restic_backup_data_added_bytes"; unit = "bytes"; })
      (stat { id = 9; title = "Duration last run"; x = 16; y = 5; w = 4; h = 4; expr = "restic_backup_duration_seconds"; unit = "dtdurations"; })
      (stat {
        id = 10; title = "Exit code"; x = 20; y = 5; w = 4; h = 4; expr = "restic_backup_exit_code";
        mappings = [ { type = "value"; options = {
          "0" = { text = "0 – OK"; color = "green"; index = 0; };
          "3" = { text = "3 – some files unreadable"; color = "orange"; index = 1; };
        }; } ];
        steps = [ { color = "red"; value = null; } ];
      })

      (graph { id = 11; title = "Repository size"; x = 0; y = 9; w = 12; h = 8; unit = "bytes";
        expr = "restic_repo_size_bytes"; legend = "stored (compressed)"; })
      (graph { id = 12; title = "Data added per run"; x = 12; y = 9; w = 12; h = 8; unit = "bytes";
        expr = "restic_backup_data_added_bytes"; legend = "added"; })
      (graph { id = 13; title = "Files per run"; x = 0; y = 17; w = 12; h = 8; unit = "none";
        expr = ''label_replace(restic_backup_files_new, "kind", "new", "", "") or label_replace(restic_backup_files_changed, "kind", "changed", "", "")'';
        legend = "{{kind}}"; })
      (graph { id = 14; title = "Duration per run"; x = 12; y = 17; w = 12; h = 8; unit = "s";
        expr = "restic_backup_duration_seconds"; legend = "duration"; })

      (panel {
        id = 15; title = "Backed up paths"; type = "table"; x = 0; y = 25; w = 12; h = 6;
        targets = [ ((target "restic_backup_path_info" "") // { instant = true; range = false; format = "table"; }) ];
        transformations = [ { id = "organize"; options.indexByName = { }; options.excludeByName = {
          Time = true; Value = true; __name__ = true; instance = true; job = true;
        }; } ];
      })
    ];
  };
in
{
  options.restic.paths = mkOption {
    type = types.listOf types.str;
    default = [];
    description = "Paths that should be backed up";
  };

  config = {
    environment.systemPackages = [ pkgs.restic restic-repo ];

    systemd.tmpfiles.rules = [
      "d /var/lib/restic 0700 root root -"
      "d ${textfileDir} 0755 root root -"
      "L+ ${textfileDir}/restic-paths.prom - - - - ${pathsProm}"
    ];

    services.prometheus.exporters.node.extraFlags = [ "--collector.textfile.directory=${textfileDir}" ];

    services.grafana.provision.dashboards.settings.providers = [
      { name = "backups"; options.path = pkgs.writeTextDir "backups.json" (builtins.toJSON dashboard); }
    ];

    systemd.timers.restic-backup = {
      wantedBy = [ "timers.target" ];
      timerConfig = { OnCalendar = "weekly"; Persistent = true; };
    };

    systemd.services.restic-backup = {
      description = "Restic Backup Service";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      # Don't snapshot empty mountpoints when a LUKS disk isn't unlocked
      unitConfig.RequiresMountsFor = config.restic.paths;
      serviceConfig = {
        Type = "oneshot";
        CacheDirectory = "restic";
        Environment = [ "RESTIC_CACHE_DIR=/var/cache/restic" ];
        EnvironmentFile = config.age.secrets.healthchecks.path;
        ExecStart = backupScript;
      };
    };

    # Reads back a random 5% of the pack data each month to catch silent corruption
    systemd.timers.restic-check = {
      wantedBy = [ "timers.target" ];
      timerConfig = { OnCalendar = "monthly"; Persistent = true; RandomizedDelaySec = "1h"; };
    };

    systemd.services.restic-check = {
      description = "Restic repository check";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" "restic-backup.service" ];
      serviceConfig = {
        Type = "oneshot";
        CacheDirectory = "restic";
        Environment = [ "RESTIC_CACHE_DIR=/var/cache/restic" ];
        ExecStart = checkScript;
      };
    };
  };
}
