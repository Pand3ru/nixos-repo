{ nixpkgs, home-manager, ... }:
let
  sharedArgs = config: {
    systemSettings = config.systemSettings;
    userSettings = config.userSettings;
    inputs = config.inputs;
    helpers = config.helpers;
  };

  newSystemSettings = {
    system ? "x86_64-linux",
    hostname ? "linux",

    useHMasModule ? false,

    keymap ? "en",
    en-locale ? "en_US.UTF-8",
    de-locale ? "de_DE.UTF-8",
    timezone ? "Europe/Berlin",

    extraSettings ? {},
  }: { inherit system hostname useHMasModule keymap en-locale de-locale timezone extraSettings; };

  newUserSettings = {
    username ? "panderu",
    displayname ? "panderu",

    terminal ? "alacritty", 
    browser ? "firefox",
    editor ? "nvim",
    wm ? "gnome",

    extraSettings ? {},
  }: {
    installationPath = "/home/${username}/nixos";
      inherit username displayname terminal browser editor wm extraSettings;
  };

  newSystemConfig = config: nixpkgs.lib.nixosSystem {
    system = config.systemSettings.system;
    modules = [ 
      ../hosts/${config.name}/configuration.nix 
      config.inputs.agenix.nixosModules.default
    ] ++ nixpkgs.lib.optionals config.systemSettings.useHMasModule [
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;

        home-manager.extraSpecialArgs = sharedArgs config;
        home-manager.users.${config.userSettings.username} = import ../hosts/${config.name}/home.nix;
      }
    ];

    specialArgs = sharedArgs config;
  };
  
  newHMConfig = config: home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.${config.systemSettings.system};
    modules = [ 
      ../hosts/${config.name}/home.nix
    ];
    extraSpecialArgs = sharedArgs config;
  };
  
in {
  inherit newSystemSettings newUserSettings;
  inherit newSystemConfig newHMConfig;
}
