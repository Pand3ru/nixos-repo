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
	alacritty
	firefox
	git
	curl
	feh
	lxappearence
	xfce.xfce4-settings
	pywal
	imagemagick
	wireguard-tools
  ];
}
