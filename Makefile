.PHONY: build update gc rs agenix

HOST ?= thinkpad

rs:
	sudo nix-env --delete-generations +5
	echo Please run gc next

build:
	sudo nixos-rebuild switch --flake .#$(HOST)

update:
	nix flake update
	sudo nixos-rebuild switch --flake .#$(HOST)

gc:
	sudo nix-collect-garbage -d

agenix:
	nix shell github:ryantm/agenix
