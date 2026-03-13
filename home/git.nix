{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Pand3ru";
        email = "github@pankratov.de";
      };
      init.defaultBranch = "main";
    };
  };
}
