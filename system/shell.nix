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
    s = "v /tmp/scratch-`shuf -i1000-9999 -n1`.md"; # creates a random scratch file

    more = "less";
    wget = "wget -c";
    mkdir = "mkdir -pv";

    server = "ssh -p 59454 panderu@panderu.org";
    gs = "git status";
    gd = "git diff";
    v = "nvim";
    vim = "nvim";
    c = "clear";
    img = "loupe";

    nix-shell = ''nix-shell --run "zsh"'';
  };

  environment.variables = {
    VISUAL = userSettings.editor;
    EDITOR = userSettings.editor;
  };
}
