{ config, pkgs, userSettings, systemSettings, ... }:
let 
  paths = [ ];
in
{
  imports = [
    # System
    ./hardware-configuration.nix 
    ../../system/secrets.nix
    ../../system/bios.nix
    ../../system/bootloader.nix
    ../../system/nh.nix
    ../../system/shell.nix
    # Server
    ../../system/ssh.nix
    ../../system/user.nix
    ../../system/locale.nix
    ../../system/restic-backups.nix
    ../../system/monitoring.nix
    ../../system/traffic-logs.nix
    # Networking
    ../../system/networking_server.nix
    ../../system/ddns.nix
    ../../system/dnsmasq.nix
    ../../system/firewall.nix
    ../../system/wireguard.nix
    # Media
    ../../system/jellyfin.nix
    ../../system/navidrome.nix
    # Web 
    ../../system/caddy.nix
    ../../system/copyparty.nix
    ../../system/desk.nix
    ../../system/desk-stats.nix
    ../../system/desk-backup.nix
    ../../system/vaultwarden.nix
  ];

  
  restic.paths = [
    "/mnt/cloud/"
    "/var/lib/vaultwarde/backup"
  ];

  # Initramfs ssh daemon to unlock luks remotely
  boot.initrd.availableKernelModules = [ "e1000e" ];
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;
      authorizedKeys = config.users.users.panderu.openssh.authorizedKeys.keys;
      hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    };
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.11";
}
