{ config, pkgs, userSettings, ... }:
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
  };

  programs.virt-manager.enable = true;

  users.users.${userSettings.username}.extraGroups = [ "libvirtd" ];

  environment.systemPackages = with pkgs; [
    virt-viewer
    spice-gtk
  ];
}
