{
  description = "Panderu's very own NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
  in {
    nixosConfigurations.thinkpad =
      nixpkgs.lib.nixosSystem {
        inherit system;

	modules = [
	  ./hosts/thinkpad/configuration.nix
	  ./hosts/thinkpad/hardware-configuration.nix

	  home-manager.nixosModules.home-manager
	  {
	    home-manager.users.panderu =
	      import ./home/panderu.nix
	  };
	];
    };
  };
}
