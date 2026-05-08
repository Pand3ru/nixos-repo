{
  description = "Panderu's very own NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    agenix.url = "github:ryantm/agenix";
    copyparty.url = "github:9001/copyparty";
  };

  outputs = { self, nixpkgs, home-manager, agenix, nix-vscode-extensions, nixpkgs-unstable, ... }@inputs:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [ nix-vscode-extensions.overlays.default ];
    };

    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
      overlays = [ nix-vscode-extensions.overlays.default ];
    };

    helpers = import ./util/helpers.nix { inherit  nixpkgs home-manager; };
        
    thinkpad = {
      name = "thinkpad";
      systemSettings = helpers.newSystemSettings {
        hostname = "TwinkPad";
        useHMasModule = true;
      };

      userSettings = helpers.newUserSettings { };
      inputs = inputs // { inherit pkgs-unstable; };
      inherit helpers;
    };

    server = {
      name = "server";
      systemSettings = helpers.newSystemSettings {
        hostname = "homelab";
        useHMasModule = true; # I think installing HM is okay since we A use it as a module and B it provides the ability to also use the same config for stuff like neovim. I think I need to edit the shell command so that zellij doesnt start itself inside a zellij instance (TODO)
      };

      userSettings = helpers.newUserSettings { };
      inherit inputs; 
      inherit helpers;
    };

    nixosName = config: "${config.name}";
    homeName = config: "${config.name}@${config.userSettings.username}";

    mkSysCfg = config: {
        nixosConfigurations."${nixosName config}" = (helpers.newSystemConfig config);
    };
    mkAllCfg = config:
      (mkSysCfg config)
      // lib.optionalAttrs (!config.systemSettings.useHMasModule) {
        homeConfigurations."${homeName config}" =
          helpers.newHMConfig config;
      };

  in lib.foldr lib.attrsets.recursiveUpdate {} [
    (mkAllCfg thinkpad)
    (mkAllCfg server)
  ];
}
