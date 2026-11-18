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
    ../../system/fail2ban.nix
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
    ../../system/forgejo.nix
    ../../system/texlyre.nix
  ];

  
  restic.paths = [
    "/mnt/cloud/"
    "/var/lib/vaultwarde/backup"
    "/var/lib/forgejo/dump"
  ];

  # Initramfs ssh daemon to unlock luks remotely
  boot.initrd.availableKernelModules = [ "e1000e" ];
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;
      # Dedicated key (~/.ssh/server_initramfs), not valid for any login on the running system.
      # Forced command: no shell, no forwarding, only answers the pending LUKS passphrase prompts
      # (systemd stage 1, so systemd's agent instead of cryptsetup-askpass; needs a pty for the prompt).
      # Root's shell stays bash: sshd runs the forced command through `<shell> -c`.
      authorizedKeys = [
        ''restrict,pty,command="/bin/systemd-tty-ask-password-agent --query" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4vbHJmb8KAmCJUVAJCKBZSODiMva+7/43lbrcewoke panderu-initrd-unlock''
      ];
      hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    };
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.11";
}
