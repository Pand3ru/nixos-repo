{ config, pkgs, lib, ... }:
let
  fontName = "JetBrainsMono Nerd Font";
  fontSize = 12;

  # Only WhiteSur's app icons are used (see whitesur-apps-icon-theme.nix);
  # status/places/actions/etc. fall back to Adwaita, since WhiteSur's
  # versions of those (e.g. the wifi/bluetooth panel icons) render too thin
  # to read at panel size.
  whitesurAppsIcons = pkgs.callPackage ../pkgs/whitesur-apps-icon-theme.nix {
    whitesur-icon-theme = pkgs.whitesur-icon-theme.override { themeVariants = [ "default" ]; };
  };
  mactahoeGtk = pkgs.callPackage ../pkgs/mactahoe-gtk-theme.nix { };
in
{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    (nerd-fonts.jetbrains-mono)
    adwaita-icon-theme
    whitesurAppsIcons
  ];

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;

    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  gtk = {
    enable = true;
    font = {
      name = fontName;
      size = fontSize;
    };
    theme = {
      # "-solid" trades the default variant's translucent sidebars/popovers
      # (e.g. gnome-control-center's sidebar) for a flat grey background.
      name = "MacTahoe-Dark-solid";
      package = mactahoeGtk;
    };
    # home-manager 26.05 changed gtk4's theme default from following
    # gtk.theme to null; keep GTK4 apps themed the same as GTK3 ones.
    gtk4.theme = config.gtk.theme;

    iconTheme = {
      name = "WhiteSur-Apps-dark";
      package = whitesurAppsIcons;
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      keyboard.bindings = [
        { key = "V"; mods = "Control"; action = "Paste"; }
      ];

      window = {
        opacity = 1.0;
        padding = {
          x = 10;
          y = 10;
        };
        decorations = "Full";
      };
      font = {
        normal = {
          family = fontName;
          style = "Regular";
        };
        bold = {
          family = fontName;
          style = "Bold";
        };
        italic = {
          family = fontName;
          style = "Italic";
        };
        bold_italic = {
          family = fontName;
          style = "Bold Italic";
        };
        size = fontSize + 2;
      };
    };
  };
}
