{ config, lib, pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.caddy = {
    enable = true;
    email = "acme@pankratov.de"; 
  };

  systemd.services.caddy.serviceConfig = {
    ProtectHome = "read-only";
  };
}
