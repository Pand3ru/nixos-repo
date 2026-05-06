{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../system/bios.nix
    ../../system/bootloader.nix
    ../../system/disks.nix
    ../../system/firewall.nix
    ../../system/flatpak.nix
    ../../system/gnome.nix
    ../../system/locale.nix
    ../../system/steam.nix
    ../../system/shell.nix
    ../../system/networking.nix
    ../../system/touchpad.nix
    ../../system/power.nix
    ../../system/sound.nix
    ../../system/user.nix
    ../../system/nh.nix
    ../../system/man.nix
    ../../system/sudo.nix
    ../../system/printing.nix

    # I am still looking for reasons. Until then, no
    #../../system/ssh.nix 
  ];

  networking.firewall = rec {
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };

  nixpkgs.overlays = [
    inputs.nix-vscode-extensions.overlays.default
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.11";
}
