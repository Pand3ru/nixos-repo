{ config, lib, pkgs, ... }:
{
  # dmenu/krunner-style launcher: ArcMenu's "runner" layout is a search bar
  # drawn by the shell itself, so it floats above everything and takes focus
  # right away. Opened with <Super>p or the button at the left of the panel.
  dconf.settings = {
  "org/gnome/shell/extensions/arcmenu" = {
    menu-layout = "runner";
    runner-position = "Centered";
    position-in-panel = "Left";

    arcmenu-hotkey = [ "<Super>p" ];
    # Otherwise ArcMenu grabs a bare Super tap, which is disabled on purpose
    # (see overlay-key in settings.nix).
    arcmenu-hotkey-overlay-key-enabled = false;
  };
  };
}
