{ config, pkgs, lib, ...}:
{
  systemd.services.fix-trackpad-resume = {
    description = "Rebind Elan trackpad after resume";
    after = [ "post-resume.target" ];
    wantedBy = [ "post-resume.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "fix-trackpad" ''
DEVICE_TRACKPAD=$(${pkgs.coreutils}/bin/ls -l /sys/bus/i2c/drivers/elan_i2c/ | ${pkgs.gawk}/bin/awk '{print $9}' | ${pkgs.gawk}/bin/awk '/[0-9]/')
        ${pkgs.coreutils}/bin/echo $DEVICE_TRACKPAD > /sys/bus/i2c/drivers/elan_i2c/unbind || true
        ${pkgs.coreutils}/bin/sleep 0.5
        ${pkgs.coreutils}/bin/echo $DEVICE_TRACKPAD > /sys/bus/i2c/drivers/elan_i2c/bind || true
      '';
    };
  };
}
