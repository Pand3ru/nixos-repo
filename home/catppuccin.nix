{ config, lib, pkgs, options, userSettings, inputs, ... }:
let
  src = "${inputs.catppuccin}/modules";
  catppuccinLib = import "${src}/lib" { inherit options config lib pkgs; };

  # Only pull in the per-app modules we actually use. Importing the flake's
  # full module set (catppuccin.homeModules.catppuccin) breaks: its vscode.nix
  # module unconditionally reaches for programs.cursor/vscodium/windsurf/kiro/
  # antigravity, none of which exist in our pinned home-manager release.
  wantedModules = map (name: "${src}/home-manager/${name}.nix") [
    "alacritty"
    "firefox"
    "thunderbird"
    "zellij"
  ];
in
{
  imports = [
    (lib.modules.importApply "${src}/global.nix" { catppuccinModules = wantedModules; })
  ];

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "mauve";

    # Thunderbird's module themes a profile named "catppuccin-<flavor>-<accent>"
    # by default, which wouldn't touch our actual profile. Point it there.
    thunderbird.profile = userSettings.username;
  };
}
