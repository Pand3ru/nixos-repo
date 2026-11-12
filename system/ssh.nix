{ config, lib, systemSettings, userSettings, ... }:
{
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
    ports = [ 59454 ];
  };

  users.users.${userSettings.username}.openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIBPfW+XOeE2uRMcya7v67oisrcfI37/86ttBHNzmhPXJAAAABHNzaDo= Panderu"
  ];
}
