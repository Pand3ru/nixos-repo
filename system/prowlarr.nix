{ config, ... }: {
  services.prowlarr = {
    enable = true;
    openFirewall = false;
  };

    services.caddy.virtualHosts."http://prowlarr.home".extraConfig = ''
      reverse_proxy 192.168.100.1:9696
    '';

  systemd.services.prowlarr = {
    bindsTo = [
      "netns@vpn.service"
      "vpn-veth.service"
      "wireguard-outbound_vpn.service"
    ];
    after = [
      "netns@vpn.service"
      "vpn-veth.service"
      "wireguard-outbound_vpn.service"
    ];
    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/vpn";
    };
  };
}
