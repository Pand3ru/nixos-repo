{ config, lib, pkgs, userConfig, ... }: 
{
  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;
    addKeysToAgent = "confirm";
  };

  programs.ssh.matchBlocks = {
    github = {
      hostname = "github.com";
      user = "Pand3ru";
      identityFile = "~/.ssh/github";
    };

    server = {
      hostname = "panderu.org";
      port = 59454;
      user = "panderu";
      identityFile = "~/.ssh/serverKey";
    };
  };
}
