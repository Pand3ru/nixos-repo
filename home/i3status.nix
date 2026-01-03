{ config, pkgs, lib, ... }:

{
  programs.i3status = {
    enable = true;
    
    general = {
      colors = true;
      interval = 5;
      output_format = "i3bar";
      color_good = "#a3be8c";
      color_degraded = "#ebcb8b";
      color_bad = "#bf616a";
    };

    modules = {
      "ethernet _first_" = {
        enable = false;
      };
      "wireless _first_" = {
        position = 1;
        settings = {
          format_up = "󰖩";     
          format_down = "󰖪";  
          format_quality = "";
        };
      };      "ipv6" = {
        enable = false;
      };
      "cpu_usage" = {
        enable = false;
      };
      "cpu_temperature 0" = {
        enable = false;
      };
      "memory" = {
        enable = false;
      };
      "load" = {
        enable = false;
      };
      "volume master" = {
        enable = false;
      };

      "battery all" = {
        position = 1;
        settings = {
          format = "%status %percentage";
          format_down = "";
          status_chr = "󰂄";
          status_bat = "󰁹";
          status_unk = "󰂑";
          status_full = "󰁹";
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
          format = "%d.%m %H:%M  ";
        };
      };
    };
  };
}
