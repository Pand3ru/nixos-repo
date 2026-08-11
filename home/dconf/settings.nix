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
      "pop-shell@System76"
      "blur-my-shell@aunetx"
      "just-perfection-desktop@just-perfection"
      "gsconnect@andyholmes.github.io"
      "dash-to-dock@micxgx.gmail.com"
      "tilingshell@ferrarodomenico.com"
    ];
  };

  "org/gnome/desktop/background" = {
    picture-uri = "file:///home/panderu/wallpaper.png";
    picture-uri-dark = "file:///home/panderu/wallpaper.png";
    picture-options = "zoom";
  };

  "org/gnome/desktop/peripherals/mouse" = {
    natural-scroll = false;
  };

  "org/gnome/shell/extensions/pop-shell" = {
    tile-by-default = false;
    active-hint = false; 
    show-decoration = false;
  };
  
  "org/gnome/desktop/peripherals/touchpad" = {
    natural-scroll = false;
  };

  "org/gnome/mutter" = {
    dynamic-workspaces = false;
  };

  "org/gnome/desktop/wm/preferences" = {
    num-workspaces = 4;
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

    close = [ "<Super>," ];
    minimize = [ "" ];
    toggle-maximized = [ "<Super>f" ];
    toggle-fullscreen = [ "F11" ];
    show-desktop = [ "" ];
  };

  "org/gnome/settings-daemon/plugins/media-keys" = {
    screensaver = [ "<Alt>l" ];
    terminal = [ "<Super>Return" ]; 
    home = [ "" ];
    www = [ "" ];
    email = [ "" ];
    calculator = [ "" ];
  };

  "org/gnome/shell/extensions/just-perfection" = {
    hide-window-titlebars = true;
  };

  "org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
  };
};

}
