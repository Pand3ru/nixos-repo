{ config, pkgs, lib, ... }:
let
  fontName = "JetBrainsMono Nerd Font";
  fontSize = 12;
in
{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    (nerd-fonts.jetbrains-mono)
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
}
