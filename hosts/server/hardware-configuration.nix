{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "uas" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/09cbd897-c658-4613-8cbd-6c316e127065";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/72D4-4A88";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  fileSystems."/mnt/media" =
    { device = "/dev/disk/by-uuid/52bf1212-b910-4d9c-b46c-fea55b31ac47";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."extdisk".device = "/dev/disk/by-uuid/77124004-c3c4-4122-a93b-5ce3457cf145";

  fileSystems."/mnt/cloud" =
    { device = "/dev/disk/by-uuid/00005428-8ab2-43ed-994e-b4900297d823";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."cloud_crypt".device = "/dev/disk/by-uuid/2ac03a3a-6974-4d85-9479-b4b45546e851";

  fileSystems."/mnt/media2" =
    { device = "/dev/disk/by-uuid/3d473664-2edc-465f-89a4-d2adf6a3b081";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."media2_crypt".device = "/dev/disk/by-uuid/c942ef6a-79ce-4721-87f1-ccce3c7aed24";

  swapDevices =
    [ { device = "/dev/disk/by-uuid/a281f6fb-37f6-409f-ac10-47c275573b0c"; }
    ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
