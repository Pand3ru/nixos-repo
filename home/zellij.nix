{ config, pkgs, systemSettings, userSettings, ... }:
{
  # https://zellij.dev/documentation/options.html
  programs.zellij = {
    enable = true;
    settings = {
    };
  };
}
