{ config, lib, pkgs, ... }:
{
  dconf.enable = true;

  home.file."wallpaper.png".source = ../assets/wallpaper.png;

  home.packages = with pkgs; [
    gnomeExtensions.blur-my-shell
    gnomeExtensions.just-perfection
    gnomeExtensions.gsconnect
    gnomeExtensions.pop-shell
  ];

  home.file.".config/mimeapps.list" = {
    text = ''
      [Default Applications]
      x-scheme-handler/http=firefox.desktop
      x-scheme-handler/https=firefox.desktop
      text/html=firefox.desktop
      x-scheme-handler/mailto=thunderbird.desktop
      application/vnd.ms-outlook=thunderbird.desktop
    '';
    force = true; 
  };

  dconf.settings = {
  "org/gnome/shell" = {
    disable-user-extensions = false;
    enabled-extensions = [
      "pop-shell@System76"
      "blur-my-shell@aunetx"
      "just-perfection-desktop@just-perfection"
      "gsconnect@andyholmes.github.io"
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

  "org/gnome/desktop/wm/keybindings" = {
    switch-to-workspace-1 = [ "<Super>h" ];
    switch-to-workspace-2 = [ "<Super>j" ];
    switch-to-workspace-3 = [ "<Super>k" ];
    switch-to-workspace-4 = [ "<Super>l" ];
  
    move-to-workspace-1 = [ "<Super><Shift>h" ];
    move-to-workspace-2 = [ "<Super><Shift>j" ];
    move-to-workspace-3 = [ "<Super><Shift>k" ];
    move-to-workspace-4 = [ "<Super><Shift>l" ];

    # Remove defaults
    switch-applications = [ ];
    switch-windows = [ ];

    close = [ "<Super>," ];
    minimize = [ "" ];
    toggle-maximized = [ "<Super>f" ];
    toggle-fullscreen = [ "" ];
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
