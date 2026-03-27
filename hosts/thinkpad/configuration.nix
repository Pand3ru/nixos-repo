{ config, pkgs, lib, ... }:

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
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.11";
}
