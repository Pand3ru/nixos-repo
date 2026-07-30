{ config, pkgs, systemSettings, userSettings, ... }:
{
  # https://zellij.dev/documentation/options.html
  programs.zellij = {
    enable = true;
    settings = {
      show_startup_tips = false;
      show_release_notes = false;
      # Skip the session-manager welcome/picker screen and drop straight
      # into a new session on startup.
      plugins.welcome-screen = {
        _props.location = "zellij:session-manager";
        welcome_screen = false;
      };

      # `catppuccin.nix` sets `theme = "catppuccin-mocha"` globally; our
      # installed zellij doesn't ship that theme built in, so we define the
      # official Catppuccin Mocha palette by hand here (high-contrast on
      # purpose, so selection/highlight colors are actually visible).
      themes.catppuccin-mocha = {
        fg = "#cdd6f4";
        bg = "#1e1e2e";
        black = "#45475a";
        red = "#f38ba8";
        green = "#a6e3a1";
        yellow = "#f9e2af";
        blue = "#89b4fa";
        magenta = "#f5c2e7";
        cyan = "#94e2d5";
        white = "#bac2de";
        orange = "#fab387";
      };
    };
  };
}
