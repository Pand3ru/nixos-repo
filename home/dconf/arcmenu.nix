{ config, lib, pkgs, ... }:
{
  dconf.settings = {
  "org/gnome/shell/extensions/arcmenu" = {
    menu-layout = "runner";
    runner-position = "Centered";
    position-in-panel = "Left";

    arcmenu-hotkey = [ "<Super>p" ];
    # Don't grab a bare Super tap
    arcmenu-hotkey-overlay-key-enabled = false;
  };
  };
}
