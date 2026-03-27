{ nixpkgs, home-manager, ... }:
let
  newSystemSettings = {
    system ? "x86_64-linux",
    hostname ? "linux",

    keymap ? "en",
    en-locale ? "en_US.UTF-8",
    de-locale ? "de_DE.UTF-8",
    timezone ? "Europe/Berlin",

    extraSettings ? {},
  }: { inherit system hostname keymap en-locale de-locale timezone extraSettings; };

  newUserSettings = {
    username ? "panderu",
    displayname ? "panderu",

    terminal ? "alacritty", 
    browser ? "firefox",
    editor ? "nvim",
    wm ? "gnome",

    extraSettings ? {},
  }: {
    dotfilesDir = "/home/${username}/.dotfiles";
      inherit username displayname terminal browser editor wm extraSettings;
  };

  newSystemConfig = config: nixpkgs.lib.nixosSystem {
    system = config.systemSettings.system;
    modules = [ ../hosts/${config.name}/configuration.nix ];
    specialArgs = {
      systemSettings = config.systemSettings;
      userSettings = config.userSettings;
      inputs = config.inputs;
      helpers = config.helpers;
    };
  };
  
  newHMConfig = config: home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.${config.systemSettings.system};
    system = config.systemSettings.system;
    modules = [ ../hosts/${config.name}/home.nix ];
    specialArgs = {
      systemSettings = config.systemSettings;
      userSettings = config.userSettings;
      inputs = config.inputs;
      helpers = config.helpers;
    };
  };
  
in {
  inherit newSystemSettings newUserSettings;
  inherit newSystemConfig newHMConfig;
}
