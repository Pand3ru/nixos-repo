{ config, lib, pkgs, userSettings, ... } :
{
  users.users.${userSettings.username}= {
    isNormalUser = true;
    description = userSettings.displayname;
    extraGroups = [ "networkmanager" "wheel" "dialout" ];
    initialPassword = "${userSettings.username}";
    shell = "${pkgs.zsh}/bin/zsh";
    packages = with pkgs; [ ];
  };
}
