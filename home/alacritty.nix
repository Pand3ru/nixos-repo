{ config, pkgs, lib, ... }:

{
  home.file.".config/alacritty/alacritty.toml".text = ''
    [window]
    opacity = 0.8
    padding.x = 10
    padding.y = 10
    decorations = "Full"
    decorations_theme_variant = "Dark"

    [font]
    size = 14.0

    [font.normal]
    family = "FiraCode Nerd Font"
    style = "Book"

    [font.bold]
    family = "FiraCode Nerd Font"
    style = "Bold"

    [font.italic]
    family = "FiraCode Nerd Font"
    style = "Oblique"

    [font.bold_italic]
    family = "FiraCode Nerd Font"
    style = "Bold Oblique"
  '';
}

