{ config, lib, pkgs, userConfig, ... }: 
{
  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };

  programs.ssh.matchBlocks = {
    "*" = {
      forwardAgent = false;
      addKeysToAgent = "confirm";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };

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
