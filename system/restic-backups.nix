{ config, pkgs, lib, ... }:
with lib;
let
  envFiles = [
    config.age.secrets.backup-user.path
    config.age.secrets.backup-host.path
    config.age.secrets.backup-storage-pass.path
    config.age.secrets.backup-restic-pass.path
  ];

  repoArgs = ''-r "sftp:$BACKUP_USER@$BACKUP_HOST:backup/restic" -o sftp.args="-p 23 -i ${config.age.secrets.backup-sk.path} -o StrictHostKeyChecking=no"'';

  restic-repo = pkgs.writeShellScriptBin "restic-repo" ''
    set -eu
    set -a
    ${concatMapStringsSep "\n" (f: ". ${f}") envFiles}
    set +a
    export RESTIC_CACHE_DIR="''${RESTIC_CACHE_DIR:-/var/cache/restic}"
    exec ${pkgs.restic}/bin/restic ${repoArgs} "$@"
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

    systemd.timers.restic-backup = {
      wantedBy = [ "timers.target" ];
      timerConfig = { OnCalendar = "weekly"; Persistent = true; };
    };

    systemd.services.restic-backup = {
      description = "Restic Backup Service";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        CacheDirectory = "restic";
        Environment = [ "RESTIC_CACHE_DIR=/var/cache/restic" ];
        ExecStart = "${restic-repo}/bin/restic-repo backup ${concatStringsSep " " config.restic.paths}";
      };
    };
  };
}
