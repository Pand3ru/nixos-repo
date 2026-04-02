{ config, ... }: {
  services.prowlarr = {
    enable = true;
    openFirewall = false;
  };

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
      ExecStartPre = "/etc/vpn-check.sh";
    };
  };
}
