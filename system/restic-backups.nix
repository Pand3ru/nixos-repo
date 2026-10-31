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

  # Pings healthchecks.io on success and on failure, so a missed or failed run both alert
  backupScript = pkgs.writeShellScript "restic-backup" ''
    set -u
    ping() { ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 -o /dev/null "$HC_BACKUP_URL$1" || true; }

    if ${restic-repo}/bin/restic-repo backup ${concatStringsSep " " config.restic.paths} \
      && ${restic-repo}/bin/restic-repo forget --prune --keep-weekly 8 --keep-monthly 12; then
      ping ""
    else
      ping "/fail"
      exit 1
    fi
  '';
in
{
  options.restic.paths = mkOption {
    type = types.listOf types.str;
    default = [];
    description = "Paths that should be backed up";
  };

  config = {
    environment.systemPackages = [ pkgs.restic restic-repo ];

    systemd.tmpfiles.rules = [ "d /var/lib/restic 0700 root root -" ];

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
        ExecStart = "${restic-repo}/bin/restic-repo check --read-data-subset=5%%";
      };
    };
  };
}
