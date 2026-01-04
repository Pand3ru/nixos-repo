{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "Pand3ru";
    userEmail = "github@pankratov.de";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
