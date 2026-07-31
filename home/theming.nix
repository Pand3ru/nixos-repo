{ config, pkgs, lib, ... }:
let
  fontName = "JetBrainsMono Nerd Font";
  fontSize = 12;
in
{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    (nerd-fonts.jetbrains-mono)
    adwaita-icon-theme
  ];

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;

    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  gtk = {
    enable = true;
    font = {
      name = fontName;
      size = fontSize;
    };
    theme = {
      name = "Adwaita-dark";
    };
    # home-manager 26.05 changed gtk4's theme default from following
    # gtk.theme to null; keep GTK4 apps themed the same as GTK3 ones.
    gtk4.theme = config.gtk.theme;
  };

  programs.alacritty = {
    enable = true;
    settings = {
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
