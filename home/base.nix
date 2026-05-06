{ config, pkgs, ...}:
{
  home.sessionVariables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
    NIXOS_OZONE_WL = "1";
    MOZ_LEGACY_PROFILES = "1";
  };

  home.packages = with pkgs; [
	anki-bin
	signal-desktop
    spotify
	curl
	imagemagick
	wireguard-tools
	gnumake
	cargo
    zathura
    filezilla
    vlc
    dnsutils
    flameshot
    bitwarden-desktop 
    zotero
    zed-editor
    calibre
  ];
}
