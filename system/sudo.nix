{ config, pkgs, systemSettings, userSettings, ... }:

let
  nopass = c: { command = c; options = [ "NOPASSWD"]; };
in
{
  security.sudo = {
    enable = true;

    extraRules = [{
      commands = [
        (nopass "${pkgs.systemd}/bin/systemctl suspend")
        (nopass "${pkgs.systemd}/bin/reboot")
        (nopass "${pkgs.systemd}/bin/poweroff")
      ];
      groups = [ "wheel" ];
    }];
  };
}
