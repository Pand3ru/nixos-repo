{ config, ... }: {
  services.dunst = {
    enable = true;
    settings.global = {
      font = "JetBrainsMono Nerd Font 11";
      corner_radius = 5;
      offset = "10x10";
    };
  };
}
