{ pkgs, ...}:
{
  # Creates network namespace
  systemd.services."netns@vpn" = {
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iproute2}/bin/ip netns add vpn";
      ExecStop = "${pkgs.iproute2}/bin/ip netns del vpn";
    };
  };

  # Create veth to reach services locally (192.168.100.2)
  systemd.services.vpn-veth = {
    after = [ "netns@vpn.service" ];
    bindsTo = [ "netns@vpn.service" ]; 
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "vpn-veth-up" ''
        ${pkgs.iproute2}/bin/ip link add veth-host type veth peer name veth-vpn
        ${pkgs.iproute2}/bin/ip link set veth-vpn netns vpn
        ${pkgs.iproute2}/bin/ip addr add 192.168.100.1/24 dev veth-host
        ${pkgs.iproute2}/bin/ip link set veth-host up
        ${pkgs.iproute2}/bin/ip netns exec vpn ${pkgs.iproute2}/bin/ip addr add 192.168.100.2/24 dev veth-vpn
        ${pkgs.iproute2}/bin/ip netns exec vpn ${pkgs.iproute2}/bin/ip link set veth-vpn up
      '';
      ExecStop = pkgs.writeShellScript "vpn-veth-down" ''
        ${pkgs.iproute2}/bin/ip link del veth-host
      '';
    };
  };
}
