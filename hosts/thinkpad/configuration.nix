{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./firefox.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # I hate myself for this...
  services.flatpak.enable = true;

  services.power-profiles-daemon.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-keyring
    unzip
    unrar
    vim
    wget
  ];

  services.resolved.enable = true;
  services.devmon.enable = true;
  services.udisks2.enable = true;

  services.displayManager.defaultSession = "gnome";

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.luks.devices = {
  "luks-1cb09dc0-51ba-4612-944e-1f61e715e553".device =
    "/dev/disk/by-uuid/1cb09dc0-51ba-4612-944e-1f61e715e553";
  
  "luks-0474b0fb-755d-4b08-85ff-704ae655c3bc".device =
    "/dev/disk/by-uuid/0474b0fb-755d-4b08-85ff-704ae655c3bc";
};

  networking = {
    hostName = "TwinkPad";
    networkmanager.enable = true;
  };

  # User
  users.users.panderu = {
    isNormalUser = true;
    description = "TwinkPad";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [ ];
  };

  nixpkgs.config.allowUnfree = true;

  hardware.bluetooth.enable = true;

  networking.firewall = rec {
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };

  networking.hosts = {
    "192.168.50.203" = [ "desk.home" ];
  };

  programs = {
    zsh.enable = true; 
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };
  };

  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;
  services.blueman.enable = true;

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Time & Locale
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
    LC_CTYPE="en_US.utf8";
  };

  system.stateVersion = "25.11";
}

