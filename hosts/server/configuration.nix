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
    # Networking
    ../../system/ddns.nix
    ../../system/firewall.nix
    ../../system/wireguard.nix
    ../../system/netns-vpn.nix
    ../../system/outbound_vpn.nix
    # Media
    ../../system/jellyfin.nix
    ../../system/decypharr.nix
    ../../system/prowlarr.nix
    ../../system/radarr.nix
    ../../system/sonarr.nix
    ../../system/whisparr.nix
    # Web 
    ../../system/caddy.nix
    ../../system/copyparty.nix
    ../../system/desk.nix
    ../../system/vaultwarden.nix
  ];

  
  restic.paths = [
    "/mnt/cloud/"
    "/var/lib/vaultwarde/backup"
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.11";
}
