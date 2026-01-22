{ config, pkgs, ...}:
{
  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "i3";
    SHELL = "${pkgs.zsh}/bin/zsh";
  };

  home.packages = with pkgs; [
	anki-bin
	signal-desktop
    spotify
	bemenu
	firefox
	curl
	feh
	lxappearance
	xfce.xfce4-settings
	pywal
	imagemagick
	wireguard-tools
	gnumake
	cargo
    arandr
    zathura
    filezilla
    vlc
    dnsutils
  ];
  # We do this to only have the daemon ran on local user
  services.kdeconnect.enable = true;
}
