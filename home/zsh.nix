{ config, pkgs, ...}:
let
  ohMyZshCustom = "${config.home.homeDirectory}/.config/oh-my-zsh/custom";
in {
  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "panderu";
      custom = ohMyZshCustom;
    };

    initContent = ''
      cat ~/.cache/wal/sequences
      if [[ -z $ZELLIJ ]]; then
          zellij
      fi
      clear
    '';
  };

  home.file.".config/oh-my-zsh/custom/themes/panderu.zsh-theme".text = ''
      PROMPT='%{$fg[green]%}%n@%m:%{$fg_bold[blue]%}%~ $(git_prompt_info)%{$reset_color%}%(!.#.$) '
   '';
}

