{ config, pkgs, lib, ... }:

let
  decypharr = pkgs.callPackage ../pkgs/decypharr.nix {};
in
{
  systemd.services.decypharr = {
    description = "Decypharr";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      ExecStart = "${decypharr}/bin/decypharr --config /var/lib/decypharr";
      StateDirectory = "decypharr";
      WorkingDirectory = "/var/lib/decypharr";
      DynamicUser = true;
      Restart = "on-failure";
    };
  };

  # After setup this might not be needed. Since I version lock this service anyway, I could just take the json and export it instead.
  networking.firewall = {
    allowedTCPPorts = [ 8282 ];
    allowedUDPPorts = [ 8282 ]; # Idk if they use UDP but just to be safe :)
  };
}
