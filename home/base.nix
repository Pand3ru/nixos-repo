{ config, pkgs, ...}:
{
  home.sessionVariables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
    NIXOS_OZONE_WL = "1";
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
    thunderbird
    zotero
    zed-editor
  ];

  # We do this to only have the daemon ran on local user
  #services.kdeconnect.enable = true;
}
