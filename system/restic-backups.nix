{ config, pkgs, lib, ... }:

with lib;

{
  options.restic.paths = mkOption {
    type = types.listOf types.str;
    default = [];
    description = "Paths that should be backed up";
  };

  config = {
    environment.systemPackages = [ pkgs.restic ];

    systemd.timers.restic-backup = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
    };

    systemd.services.restic-backup = {
      description = "Restic Backup Service";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      path = [ pkgs.restic ];
      serviceConfig = {
        Type = "oneshot";
        EnvironmentFile = [
          config.age.secrets.backup-user.path
          config.age.secrets.backup-host.path
          config.age.secrets.backup-storage-pass.path
          config.age.secrets.backup-restic-pass.path
        ];
        ExecStart = pkgs.writeShellScript "restic-backup" ''
          restic \
            -r sftp:$BACKUP_USER@$BACKUP_HOST:backup/restic \
            -o sftp.args="-p 23 -i ${config.age.secrets.backup-sk.path} -o StrictHostKeyChecking=no" \
            backup ${concatStringsSep " " config.restic.paths}
        '';
      };
    };
  };
}
