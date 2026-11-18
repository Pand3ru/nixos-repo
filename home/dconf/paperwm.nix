{ config, lib, pkgs, ... }:
{
  dconf.settings = {
  "org/gnome/shell/extensions/paperwm" = {
    winprops = map builtins.toJSON [
      { wm_class = "org.gnome.Nautilus"; scratch_layer = true; }
      { wm_class = "/aonsoku/i"; scratch_layer = true; }
      # Spotify sets its WM_CLASS late, may not match
      { wm_class = "/spotify/i"; scratch_layer = true; }
    ];
    cycle-width-steps = [ 0.5 1.0 ];
    overview-min-windows-per-row = 99;

    selection-border-size = 0;

    window-gap = 8;
    horizontal-margin = 8;
    vertical-margin = 8;
    vertical-margin-bottom = 8;

    show-focus-mode-icon = false;
    show-open-position-icon = false;
  };

  "org/gnome/shell/extensions/paperwm/keybindings" = {
    # Default <Super>Return would steal the terminal binding
    new-window = [ "<Super>n" ];
    close-window = [ "<Super><Shift>c" ];
    # Default <Super><Shift>c is close-window now
    switch-focus-mode = [ ];

    switch-global-left = [ "<Super>h" ];
    switch-global-right = [ "<Super>l" ];
    move-left = [ "<Super><Shift>h" "<Super><Ctrl>Left" ];
    move-right = [ "<Super><Shift>l" "<Super><Ctrl>Right" ];
    move-monitor-left = [ "<Super><Alt>h" "<Super><Shift><Ctrl>Left" ];
    move-monitor-right = [ "<Super><Alt>l" "<Super><Shift><Ctrl>Right" ];

    resize-w-dec = [ "<Super><Ctrl>h" "<Super>minus" ];
    resize-w-inc = [ "<Super><Ctrl>l" "<Super>plus" ];

    switch-down-workspace = [ "<Super>j" "<Super>Page_Down" ];
    switch-up-workspace = [ "<Super>k" "<Super>Page_Up" ];
    move-down-workspace = [ "<Super><Shift>j" "<Super><Ctrl>Page_Down" ];
    move-up-workspace = [ "<Super><Shift>k" "<Super><Ctrl>Page_Up" ];

    toggle-scratch-window = [ "<Super>s" ];
    toggle-scratch = [ "<Super><Shift>s" ];
    toggle-scratch-layer = [ "<Super><Ctrl>s" ];
    live-alt-tab = [ "<Super>Tab" ];
    live-alt-tab-backward = [ "<Super><Shift>Tab" ];
    live-alt-tab-scratch = [ "<Alt>Tab" ];
    live-alt-tab-scratch-backward = [ "<Alt><Shift>Tab" ];
  };
  };
}
