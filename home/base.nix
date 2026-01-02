{ config, pkgs, ...}:
{
  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "i3";
    SHELL = "${pkgs.zsh}/bin/zsh";
  };

  home.packages = with pkgs; [
	neovim
	anki-bin
	signal-desktop
	bemenu
	firefox
	git
	curl
	feh
	lxappearance
	xfce.xfce4-settings
	pywal
	imagemagick
	wireguard-tools
	gnumake
  ];
  # We do this to only have the daemon ran on local user
  services.kdeconnect.enable = true;
}
