{ config, pkgs, systemSettings, userSettings, ... }:

{
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;
  services.displayManager.defaultSession = "gnome";

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  environment.systemPackages = 
    with pkgs; [
      gnome-keyring
      unzip
      unrar
      vim
      wget
      gnome-network-displays
      solaar
      openh264 # this seems to maybe be related to gnome-network-displays
    ] ++ (with pkgs.gnomeExtensions; [

    # Remember to update them in the "Extensions" application
    focus # https://github.com/scaryrawr/gnome-focus
    wiggle
    paperwm
    caffeine
    desktop-cube
    just-perfection
    clipboard-history
    workspace-indicator
    blur-my-shell
    gsconnect
    solaar-extension
  ]);

  environment.gnome = {
    # List is here:
    # https://wiki.nixos.org/wiki/GNOME#Excluding_GNOME_Applications
    # https://discourse.nixos.org/t/howto-disable-most-gnome-default-applications-and-what-they-are
    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/desktop-managers/gnome.nix#L449-L471
    excludePackages = with pkgs; [
      gnome-tour

      gnome-music
      gnome-weather
      gnome-characters
      gnome-console

      geary # Mail client
      totem # Video player
      epiphany # Web browser
      seahorse # Password manager

      decibels # Audio Player
      showtime # Video Player
    ];
  };
}
