{ config, pkgs, lib, ...}:
let
  walColors = "${config.home.homeDirectory}/.cache/wal/colors-alacritty.yml";
in
{
  programs.alacritty = {

    enable = true;
    font = {
      normal = {
	family = "FiraCode Nerd Font";
	size = 14;
      };
    };
    extraConfig = lib.optionalString (builtins.pathExists walColors) ''
	import:
        - ${walColors}
    '';
  };
}
