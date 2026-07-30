{ config, pkgs, lib, ... }:

{
  virtualisation.podman = {
    enable = true;

    dockerCompat = true;

    defaultNetwork.settings.dns_enabled = true;
  };

  environment.systemPackages = with pkgs; [
    podman
    podman-compose
    slirp4netns
    fuse-overlayfs
  ];

  virtualisation.containers.policy = lib.mkForce {
    default = [
      { type = "insecureAcceptAnything"; }
    ];

    transports = {
      docker = {
        "" = [
          { type = "insecureAcceptAnything"; }
        ];
      };
      docker-daemon = {};
    };
  };
}
