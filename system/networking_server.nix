{ config, pkgs, systemSettings, userSettings, lib, ... }:
{
  # No NAT/forwarding: wireguard peers only need to reach the server itself.
  # Keep the default dhcpcd setup, switching to NetworkManager remotely could cut the connection.
  networking = {
    hostName = "homelab";
    domain = "panderu.org";
  };
}
