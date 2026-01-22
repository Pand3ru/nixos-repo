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
      vim = "nvim";
      c = "clear";
      copyDir = "find . -type f -exec sh -c 'for file; do echo \"Dateiname: $file\"; cat \"$file\"; done' sh {} + | xclip -selection clipboard";
    };

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "panderu";
      custom = ohMyZshCustom;
    };

    initContent = ''
      eval "$(ssh-agent -s)" > /dev/null
      cat ~/.cache/wal/sequences
      clear
    '';
  };

  home.file.".config/oh-my-zsh/custom/themes/panderu.zsh-theme".text = ''
      PROMPT='%{$fg[green]%}%n@%m:%{$fg_bold[blue]%}%~ $(git_prompt_info)%{$reset_color%}%(!.#.$) '
   '';
}

