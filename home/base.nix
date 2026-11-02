{ config, pkgs, inputs, ...}:
let
  pkgs-unstable = inputs.pkgs-unstable;
in
{
  home.sessionVariables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
    NIXOS_OZONE_WL = "1";
    MOZ_LEGACY_PROFILES = "1";
  };

  home.packages = with pkgs; [
	anki-bin
    aonsoku 
	signal-desktop
	curl
	imagemagick
	wireguard-tools
	gnumake
	cargo
    zathura
    filezilla
    vlc
    librepods
    dnsutils
    flameshot
    pkgs-unstable.bitwarden-desktop # stable's build is still on EOL Electron; unstable has the fix
    libreoffice
    zotero
    zed-editor
    calibre
    power-profiles-daemon
    discord
    openssl

    # Networking 
    whois 
    tcpdump 
  ];

  programs.codex.enable = true;
}
