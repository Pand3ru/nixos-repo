{ config, pkgs, userSettings, ... }:
let 
  sk = config.age.secrets.wg-private.path;
in
{
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
    extraCommands = ''
      iptables -t mangle -A FORWARD -o wg0 -p tcp --tcp-flags SYN,RST SYN \
        -j TCPMSS --clamp-mss-to-pmtu
    '';
  };

  networking.wireguard = {
    enable = true;
    interfaces = {
      wg0 = {
        privateKeyFile = sk;
        listenPort = 51820;
        ips = [ "10.0.0.1/24" ];
        peers = [
          {
            publicKey = "GCwcP0OhUA6JkJalfQqNiYKmFvvZKFv63HBmPScIVR0=";
            allowedIPs = [ "10.0.0.2/32" ];
          }
          {
            publicKey = "44Uku8Ol37OhYOMKogDfF2frYG1cMwFS1/HgdhFEqSQ=";
            allowedIPs = [ "10.0.0.10/32" ];
          }
        ];
      };
    };
  };
}
