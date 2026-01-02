{ config, pkgs, lib, ... }:

{
  programs.i3status = {
    enable = true;
    
    general = {
      colors = true;
      interval = 5;
      color_good = "#a3be8c";
      color_degraded = "#ebcb8b";
      color_bad = "#bf616a";
    };

    modules = {
      "battery all" = {
        position = 1;
        settings = {
          format = "%status %percentage";
          format_down = "";
          status_chr = "󰂄";  # charging icon
          status_bat = "󰁹";  # battery icon
          status_unk = "󰂑";  # unknown
          status_full = "󰁹"; # full battery
          path = "/sys/class/power_supply/BAT%d/uevent";
          low_threshold = 20;
          threshold_type = "percentage";
        };
      };

      "disk /" = {
        position = 2;
        settings = {
          format = "󰋊 %avail";
        };
      };

      "tztime local" = {
        position = 3;
        settings = {
          format = "󰥔 %d.%m.%Y 󰥔 %H:%M";
        };
      };
    };
  };
}
