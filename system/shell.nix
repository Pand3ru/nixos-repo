{ config, pkgs, systemSettings, userSettings, ... }:

{
  environment.shells = [ pkgs.zsh ];
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
  };

  environment.shellAliases = {
    l = "ls -alh";
    ll = "ls -l";
    ls = "ls --color=tty";

    more = "less";
    wget = "wget -c";
    mkdir = "mkdir -pv";

    server = "ssh -p 59454 panderu@panderu.org";
    gs = "git status";
    gd = "git diff";
    v = "nvim";
    vim = "nvim";
    c = "clear";
    # doesnt work under wayland. Maybe I can pull the session variable and replace the clipboard command
    #copyDir = "find . -type f -exec sh -c 'for file; do echo \"Dateiname: $file\"; cat \"$file\"; done' sh {} + | xclip -selection clipboard";
    img = "loupe";

    nix-shell = ''nix-shell --run "zsh"'';
  };

  environment.variables = {
    VISUAL = userSettings.editor;
    EDITOR = userSettings.editor;
  };
}
