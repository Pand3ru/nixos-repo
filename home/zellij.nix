{ config, pkgs, systemSettings, userSettings, ... }:
{
  # https://zellij.dev/documentation/options.html
  programs.zellij = {
    enable = true;
    settings = {
      theme = "pywal";
      themes.pywal = {
        fg = "#3e3c42";
        bg = "#120c1e";
        black = "#615c70";
        red = "#cc6739";
        green = "#7C84B1";
        yellow = "#9D90A4";
        blue = "#6D719B";
        magenta = "#877C95";
        cyan = "#CDB2BC";
        white = "#c3c2c6";
        orange = "#A38679";
      };
    };
  };
}
