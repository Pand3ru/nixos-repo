{ config, lib, pkgs, ... }:
{
  dconf.enable = true;

  home.file."wallpaper.png".source = ../assets/wallpaper.png;

  home.packages = with pkgs; [
    gnomeExtensions.pop-shell
    gnomeExtensions.blur-my-shell
    gnomeExtensions.just-perfection
    gnomeExtensions.workspace-grid
    gnomeExtensions.gsconnect
  ];

  dconf.settings = {
  "org/gnome/shell" = {
    disable-user-extensions = false;
    enabled-extensions = [
      "pop-shell@system76.com"
      "blur-my-shell@aunetx"
      "just-perfection-desktop@just-perfection"
      "workspace-grid@mathematical.coffee.gmail.com"
      "gsconnect@andyholmes.github.io"
    ];
  };

  "org/gnome/desktop/background" = {
    picture-uri = "file:///home/panderu/wallpaper.png";
    picture-uri-dark = "file:///home/panderu/wallpaper.png";
    picture-options = "zoom";
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
  };

  "org/gnome/shell/extensions/pop-shell" = {
    tile-by-default = true;
    active-hint = true;
  };
};

}
