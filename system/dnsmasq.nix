{ config, ...}:
{
  services.dnsmasq = {
    enable = true;
    settings = {
      address = [ "/desk.home/192.168.50.203" ];
      server = [ "76.76.2.2" "76.76.10.2" ];
    };
  };

  networking.firewall = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}
