{ config, pkgs, ...}:
let
  sk = config.age.secrets.outbound-vpn.path;
in 
{
  # Creates VPN connection and binds it to ns
  networking.wireguard.interfaces.outbound_vpn = {
    privateKeyFile = sk;
    interfaceNamespace = "vpn";
    ips = [ "10.2.0.2/32" "2a07:b944::2:2/128" ];
    # This option does not seem to exist. See: https://www.reddit.com/r/NixOS/comments/1dyjrbb/setting_dns_server_for_wireguard_interface/
    #dns = [ "10.2.0.1" "2a07:b944::2:1" ]; 
    peers = [{
      publicKey = "m0HsRUbWzTEDSNH9BVrsnGaA9mGaHfQlLDD2ngzgJmc=";
      endpoint = "37.120.137.226:51820";
      allowedIPs = [ "0.0.0.0/0" ];
      persistentKeepalive = 25;
    }];
  };

  systemd.services.wireguard-outbound_vpn = {
    after = [ "netns@vpn.service" ];
    bindsTo = [ "netns@vpn.service" ];
    requires = [ "netns@vpn.service" ];
  };
}
