{ config, ... }:
{
  age.identityPaths = [ 
    "/home/panderu/.ssh/thinkpad_secrets" 
    "/etc/ssh/ssh_host_ed25519_key"
  ];

  age.secrets = {
    email = {
        file = ../secrets/email.age;
    };

    ddns-url = {
      file = ../secrets/ddns-url.age;
    };

    wg-private = {
      file = ../secrets/wg-private.age;
    };

    copyparty-panderu = {
      file = ../secrets/copyparty_panderu.age;
      owner = "copyparty";
      mode = "0400";
    };

    copyparty-other = {
      file = ../secrets/copyparty_other.age;
      owner = "copyparty";
      mode = "0400";
    };

    backup-user = {
      file = ../secrets/backups_user.age;
    };

    backup-host = {
      file = ../secrets/backups_host.age;
    };

    backup-sk = {
      file = ../secrets/backups_private_key.age;
      mode = "0400";
    };

    backup-storage-pass = {
      file = ../secrets/backups_storage_pass.age;
    };

    backup-restic-pass = {
      file = ../secrets/backups_restic_pass.age;
    };

    # Env file: GF_ADMIN_PASSWORD, GF_SECRET_KEY, PUSHOVER_USER_KEY, PUSHOVER_APP_TOKEN
    grafana = {
      file = ../secrets/grafana.age;
    };

    # Env file: HC_HEARTBEAT_URL, HC_BACKUP_URL
    healthchecks = {
      file = ../secrets/healthchecks.age;
    };
  };
}
