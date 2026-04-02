{ config, pkgs, lib, ... }:
let
  decypharr = pkgs.callPackage ../pkgs/decypharr.nix {};
in
{
  systemd.services.decypharr = {
    description = "Decypharr";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = [ pkgs.rclone pkgs.fuse ];
    serviceConfig = {
      ExecStart = "${decypharr}/bin/decypharr --config /var/lib/decypharr";
      StateDirectory = "decypharr";
      WorkingDirectory = "/var/lib/decypharr";
      DynamicUser = false;
      User = "decypharr";
      Group = "decypharr";
      Restart = "on-failure";
      DeviceAllow = [ "/dev/fuse" ];
      AmbientCapabilities = [ "CAP_SYS_ADMIN" ];
      SupplementaryGroups = [ "fuse" "media" ];
    };
  };

  users.users.decypharr = {
    isSystemUser = true;
    group = "decypharr";
    extraGroups = [ "fuse" "media" ];
  };
  users.users.sonarr.extraGroups = [ "media" ];

  users.groups.decypharr = {};
  users.groups.fuse = {};
  users.groups.media = {};

  programs.fuse.userAllowOther = true;
  boot.kernelModules = [ "fuse" ];

  systemd.tmpfiles.rules = [
    "d /mnt/remote 0755 decypharr decypharr - -"
    "d /mnt/remote/realdebrid 0755 decypharr decypharr - -"
    "d /var/lib/decypharr 0755 decypharr decypharr - -"
    "d /mnt/media2/dl 0775 sonarr media - -"
  ];

  networking.firewall = {
    allowedTCPPorts = [ 8282 ];
    allowedUDPPorts = [ 8282 ];
  };
}
