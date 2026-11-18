{ config, lib, pkgs, ... }:
{
  dconf.enable = true;

  home.packages = with pkgs; [
    wl-clipboard
  ];

  home.file."wallpaper.png".source = ../../assets/10-15-Day-6k.jpg;

  dconf.settings = {
  "org/gnome/shell" = {
    disable-user-extensions = false;
    enabled-extensions = [
      "paperwm@paperwm.github.com"
      "arcmenu@arcmenu.com"
      "blur-my-shell@aunetx"
      "just-perfection-desktop@just-perfection"
      "gsconnect@andyholmes.github.io"
      "dash-to-dock@micxgx.gmail.com"
      "rounded-window-corners@fxgn"
    ];
    disabled-extensions = [ ];
  };

  "org/gnome/desktop/background" = {
    picture-uri = "file:///home/panderu/wallpaper.png";
    picture-uri-dark = "file:///home/panderu/wallpaper.png";
    picture-options = "zoom";
  };

  "org/gnome/desktop/peripherals/mouse" = {
    natural-scroll = false;
  };

  "org/gnome/desktop/peripherals/touchpad" = {
    natural-scroll = false;
  };

  "org/gnome/mutter" = {
    dynamic-workspaces = false;
    # Tapping Super alone no longer opens the overview.
    overlay-key = "";
  };

  # <Super>p (display switching by default) opens the launcher instead
  # (arcmenu.nix).
  "org/gnome/mutter/keybindings" = {
    switch-monitor = [ "XF86Display" ];
  };

  "org/gnome/desktop/wm/preferences" = {
    num-workspaces = 4;
    # No close/minimize/maximize buttons in title bars and header bars.
    button-layout = ":";
  };

  # A small, autohiding dock/app bar. It stays out of the way and only shows
  # up when the desktop is empty (no windows) or when the mouse hovers over
  # its edge, similar to the macOS dock.
  "org/gnome/shell/extensions/dash-to-dock" = {
    dock-fixed = false;
    autohide = true;
    autohide-in-fullscreen = true;
    require-pressure-to-show = false;
    intellihide = true;
    intellihide-mode = "ALL_WINDOWS";
    dash-max-icon-size = 40;
    extend-height = false;
  };

  "org/gnome/desktop/wm/keybindings" = {
    # Remove defaults
    switch-applications = [ ];
    switch-windows = [ ];

    minimize = [ "" ];
    toggle-fullscreen = [ "F11" ];
    show-desktop = [ "" ];
  };

  "org/gnome/settings-daemon/plugins/media-keys" = {
    screensaver = [ "<Alt>l" ];
    home = [ "" ];
    www = [ "" ];
    email = [ "" ];
    calculator = [ "" ];
    # GNOME 50 dropped the built-in `terminal` key, so it's a custom binding.
    custom-keybindings = [
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/"
    ];
  };

  "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal" = {
    name = "Terminal";
    command = "${config.programs.alacritty.package}/bin/alacritty";
    binding = "<Super><Shift>Return";
  };

  "org/gnome/shell/extensions/just-perfection" = {
    hide-window-titlebars = true;
    theme = true;
  };

  "org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
  };
};

}
