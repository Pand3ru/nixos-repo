let 
  thinkpad = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILlOJndagplx3FYKnu2wcF3/CbZWV3N8xAoivaCE1A0T panderu@nixos";
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxb4zgcWk5heIoNlq/bJfojM8RdMo7YsnY77X4/UKqe root@nixos";
in {
  "ddns-url.age".publicKeys = [ thinkpad server ];
  "wg-private.age".publicKeys = [ thinkpad server ];
  "outbound_vpn.age".publicKeys = [ thinkpad server ]; 
  "copyparty_panderu.age".publicKeys = [ thinkpad server ];
  "copyparty_other.age".publicKeys = [ thinkpad server ];
  "backups_user.age".publicKeys = [ thinkpad server ];
  "backups_host.age".publicKeys = [ thinkpad server ];
  "backups_private_key.age".publicKeys = [ thinkpad server ];
  "backups_storage_pass.age".publicKeys = [ thinkpad server ];
  "backups_restic_pass.age".publicKeys = [ thinkpad server ];
}
