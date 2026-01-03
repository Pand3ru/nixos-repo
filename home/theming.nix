{ config, pkgs, lib, ... }:
let
  fontName = "JetBrainsMono Nerd Font";
  fontSize = 12;
in
{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
     (nerd-fonts.jetbrains-mono)
    libsForQt5.qt5ct
    kdePackages.qt6ct
  ];

  gtk = {
    enable = true;
    font = {
      name = fontName;
      size = fontSize;
    };
    theme = {
      name = "Adwaita-dark";
    };
  };

  home.sessionVariables.QT_QPA_PLATFORMTHEME = "qt5ct";

  xresources.properties = {
    "Xft.dpi" = 96;
    "Xft.antialias" = 1;
    "Xft.hinting" = 1;
    "Xft.hintstyle" = "hintfull";
    "Xft.rgba" = "rgb";
    "Xft.autohint" = 0;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = 0.8;
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

  home.sessionVariables.I3FONT = "${fontName}:size=${toString fontSize}";
}
