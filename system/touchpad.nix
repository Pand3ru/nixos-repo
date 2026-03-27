{ config, pkgs, lib, ...}:
{
  systemd.services.fix-trackpad-resume = {
    description = "Rebind Elan trackpad after resume";
    after = [ "post-resume.target" ];
    wantedBy = [ "post-resume.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "fix-trackpad" ''
        echo "0-0015" > /sys/bus/i2c/drivers/elan_i2c/unbind || true
        sleep 0.5
        echo "0-0015" > /sys/bus/i2c/drivers/elan_i2c/bind || true
      '';
    };
  };
}
