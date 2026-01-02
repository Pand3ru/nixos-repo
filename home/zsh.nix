{ config, pkgs, ...}:
  let
    ohMyZshCustom = "${config.home.homeDirectory}/.config/oh-my-zsh/custom";
  in {
    programs.zsh = {
      enable = true;

      shellAliases = {
          ll = "ls -l";
        update = "sudo nixos-rebuild switch --flake ~/nixos#thinkpad";
        server = "ssh -p 59454 panderu@panderu.org";
        gs = "git status";
        gd = "git diff";
        v = "nvim";
      };

      oh-my-zsh = {
        enable = true;
	theme = "panderu";
	custom = ohMyZshCustom;
      };

      initExtra = ''
         if [ -f "${config.home.homeDirectory}/.cache/wal/colors.sh" ]; then
   	   source "${config.home.homeDirectory}/.cache/wal/colors.sh"
         fi
      '';
    };

    home.file.".config/oh-my-zsh/custom/themes/panderu.zsh-theme".text = ''
	PROMPT='%{$fg[green]%}%n@%m:%{$fg_bold[blue]%}%~ $(git_prompt_info)%{$reset_color%}%(!.#.$) '
    '';
}

