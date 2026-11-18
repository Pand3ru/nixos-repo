{ config, lib, pkgs, ... }:
{
  dconf.settings = {
  "org/gnome/shell/extensions/paperwm" = {
    # Float above the strip for drag and drop / quick access.
    winprops = map builtins.toJSON [
      { wm_class = "org.gnome.Nautilus"; scratch_layer = true; }
      { wm_class = "/aonsoku/i"; scratch_layer = true; }
      # Spotify sets its WM_CLASS late, so this may not always catch it.
      { wm_class = "/spotify/i"; scratch_layer = true; }
    ];
    # <Super>r toggles between half and full width. Ratios are of the usable
    # width, so <Super>r, <Super>l, <Super>r gives a 50/50 split.
    cycle-width-steps = [ 0.5 1.0 ];
    # GNOME's overview (Activities) shows all windows in a single row.
    overview-min-windows-per-row = 99;

    # No highlight border around the focused window.
    selection-border-size = 0;

    # Tighter than the 20px defaults.
    window-gap = 8;
    horizontal-margin = 8;
    vertical-margin = 8;
    vertical-margin-bottom = 8;

    show-focus-mode-icon = false;
    show-open-position-icon = false;
  };

  # Home-row layout: h/l scroll the strip (and cross to the other monitor at
  # its end), j/k switch workspaces, Shift moves the window along, Ctrl
  # resizes, Alt moves it to the other monitor. Arrow defaults are kept as a fallback. PaperWM clears any
  # conflicting GNOME binding on startup.
  "org/gnome/shell/extensions/paperwm/keybindings" = {
    # Default is <Super>Return, which would steal the terminal binding.
    new-window = [ "<Super>n" ];
    close-window = [ "<Super><Shift>c" ];
    # Its default (<Super><Shift>c) is taken by close-window above.
    switch-focus-mode = [ ];

    switch-global-left = [ "<Super>h" ];
    switch-global-right = [ "<Super>l" ];
    move-left = [ "<Super><Shift>h" "<Super><Ctrl>Left" ];
    move-right = [ "<Super><Shift>l" "<Super><Ctrl>Right" ];
    # Workspace switching (j/k) never reaches a workspace shown on the other
    # monitor, so crossing monitors gets its own binding.
    move-monitor-left = [ "<Super><Alt>h" "<Super><Shift><Ctrl>Left" ];
    move-monitor-right = [ "<Super><Alt>l" "<Super><Shift><Ctrl>Right" ];

    resize-w-dec = [ "<Super><Ctrl>h" "<Super>minus" ];
    resize-w-inc = [ "<Super><Ctrl>l" "<Super>plus" ];

    switch-down-workspace = [ "<Super>j" "<Super>Page_Down" ];
    switch-up-workspace = [ "<Super>k" "<Super>Page_Up" ];
    move-down-workspace = [ "<Super><Shift>j" "<Super><Ctrl>Page_Down" ];
    move-up-workspace = [ "<Super><Shift>k" "<Super><Ctrl>Page_Up" ];

    # Scratch layer (floating windows above the strip). <Super>s replaces
    # GNOME's quick-settings toggle; PaperWM clears that binding itself.
    toggle-scratch-window = [ "<Super>s" ];
    toggle-scratch = [ "<Super><Shift>s" ];
    toggle-scratch-layer = [ "<Super><Ctrl>s" ];
    # Alt+Tab cycles the scratch windows; Super+Tab keeps the regular
    # last-used switcher.
    live-alt-tab = [ "<Super>Tab" ];
    live-alt-tab-backward = [ "<Super><Shift>Tab" ];
    live-alt-tab-scratch = [ "<Alt>Tab" ];
    live-alt-tab-scratch-backward = [ "<Alt><Shift>Tab" ];
  };
  };
}
