{ config, pkgs, ... }: 
{
  boot.kernelParams = [ "mem_sleep_default=deep" ];
  services = { 
    tlp = {
      enable = true;
      settings = {
        PCIE_ASPM_ON_BAT = "powersupersave";

        STOP_CHARGE_THRESH_BAT0 = 95;
        STOP_CHARGE_THRESH_BAT1 = 95;
      };
    };
    upower.enable = true;
  };

}
