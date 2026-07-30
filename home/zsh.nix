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
          # Drop already-exited sessions first so they don't pile up forever;
          # this never touches sessions that are still running.
          zellij delete-all-sessions --yes >/dev/null 2>&1
          zellij
      fi
      clear
    '';
  };

  home.file.".config/oh-my-zsh/custom/themes/panderu.zsh-theme".text = ''
      PROMPT='%{$fg[green]%}%n@%m:%{$fg_bold[blue]%}%~ $(git_prompt_info)%{$reset_color%}%(!.#.$) '
   '';
}

