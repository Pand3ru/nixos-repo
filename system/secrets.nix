{ config, ... }:
{
  age.identityPaths = [ 
    "/home/panderu/.ssh/thinkpad_secrets" 
    "/etc/ssh/ssh_host_ed25519_key"
  ];

  age.secrets = {
    ddns-url = {
      file = ../secrets/ddns-url.age;
    };

    wg-private = {
      file = ../secrets/wg-private.age;
    };

    outbound-vpn = {
      file = ../secrets/outbound_vpn.age;
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
  };
}
