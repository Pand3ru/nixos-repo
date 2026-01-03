.PHONY: build update gc rs

rs:
	sudo nix-env --delete-generations +5
	echo Please run gc next

build:
	sudo nixos-rebuild switch --flake .#thinkpad

update:
	nix flake update
	sudo nixos-rebuild switch --flake .#thinkpad

gc:
	sudo nix-collect-garbage -d
