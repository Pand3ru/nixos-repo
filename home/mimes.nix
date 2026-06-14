{ pkgs, ... }:

{

  xdg.desktopEntries.cred-receiver = {
    name = "CredReceiver";
    exec = "/home/panderu/BA/Code/tools/cred-receiver/build/app %u";
    terminal = false;
    type = "Application";
  };

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/openid-credential-offer" = [
      "cred-receiver.desktop"
    ];
  };
}
