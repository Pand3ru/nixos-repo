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

    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;

    oh-my-zsh = {
      enable = true;
      theme = "panderu";
      custom = ohMyZshCustom;
    };

    initExtra = ''
      cat ~/.cache/wal/sequences
      clear
    '';
  };

  home.file.".config/oh-my-zsh/custom/themes/panderu.zsh-theme".text = ''
      PROMPT='%{$fg[green]%}%n@%m:%{$fg_bold[blue]%}%~ $(git_prompt_info)%{$reset_color%}%(!.#.$) '
   '';
}

