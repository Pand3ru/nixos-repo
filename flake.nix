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
    system = "x86_64-linux";
    lib = nixpkgs.lib;

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    commonShellHook = ''
      export IN_NIX_SHELL=1
    
      if [ -n "$PS1" ]; then
        export PS1="(nix) $PS1"
      fi
    
      parent_shell="$(ps -p $PPID -o comm=)"
    
      current_shell="$(ps -p $$ -o comm=)"
    
      if [ "$parent_shell" != "$current_shell" ]; then
        exec "$(command -v "$parent_shell")"
      fi
    '';

    mkDevShell = packages: pkgs.mkShell {
      inherit packages;
      shellHook = commonShellHook;
    };

  in
  {
    nixosConfigurations.thinkpad = lib.nixosSystem {
      inherit system;

      modules = [
        ./hosts/thinkpad/configuration.nix
        ./hosts/thinkpad/hardware-configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.users.panderu =
            import ./home/panderu.nix;
        }
      ];
    };

    devShells.${system} = {
      rust = mkDevShell (with pkgs; [
        gcc
        gnumake
        pkg-config
        rustPackages.rustc
        rustPackages.cargo
        rust-analyzer
        rustfmt
      ]);
    };
  };
}
