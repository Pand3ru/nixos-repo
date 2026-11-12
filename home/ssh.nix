{ config, lib, pkgs, userConfig, ... }: 
{
  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };

  programs.ssh.settings = {
    "*" = {
      ForwardAgent = false;
      AddKeysToAgent = "confirm";
      Compression = false;
      ServerAliveInterval = 0;
      ServerAliveCountMax = 3;
      HashKnownHosts = false;
      UserKnownHostsFile = "~/.ssh/known_hosts";
      ControlMaster = "no";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "no";
    };

    github = {
      HostName = "github.com";
      User = "Pand3ru";
      IdentityFile = "~/.ssh/github";
    };

    server = {
      HostName = "panderu.org";
      Port = 59454;
      User = "panderu";
      IdentityFile = "~/.ssh/serverKey";
    };

    # Initramfs sshd, only opens the LUKS passphrase prompt (hosts/server/configuration.nix)
    homelab-unlock = {
      HostName = "192.168.50.203"; # initrd has no WireGuard, LAN only
      Port = 2222;
      User = "root";
      IdentityFile = "~/.ssh/server_initramfs";
      IdentitiesOnly = "yes";
      RequestTTY = "yes";
    };
  };

  home.shellAliases.unlock = "ssh homelab-unlock";
}
