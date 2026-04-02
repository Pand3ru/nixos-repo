{ config, ...}:
{
  services.dnsmasq = {
    enable = true;
    settings = {
      address = [ 
      "/desk.home/192.168.50.203" 
      "/media.home/192.168.50.203"
      "/radarr.home/192.168.50.203"
      "/sonarr.home/192.168.50.203"
      "/whisparr.home/192.168.50.203"
      ];
      server = [ "76.76.2.2" "76.76.10.2" ];
    };
  };

  networking.firewall = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}
