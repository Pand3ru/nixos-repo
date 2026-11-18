{ config, ...}:
{
  services.dnsmasq = {
    enable = true;
    settings = {
      address = [ 
      "/desk.home/192.168.50.203" 
      "/media.home/192.168.50.203"
      "/grafana.home/192.168.50.203"
      ];
      server = [ "76.76.2.2" "76.76.10.2" ];
      # Bind per interface instead of the wildcard and stay off podman bridges, whose
      # 10.89.x.1:53 belongs to aardvark-dns (container name resolution, see aldine.nix).
      bind-dynamic = true;
      except-interface = "podman*";
    };
  };

  networking.firewall = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}
