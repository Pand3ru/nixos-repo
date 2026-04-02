{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "uas" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/db9d41b9-ca44-412e-a574-7f1f8e9f0785";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/1F7E-4B11";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  fileSystems."/mnt/media" =
    { device = "/dev/mapper/extdisk";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."extdisk".device = "/dev/disk/by-uuid/77124004-c3c4-4122-a93b-5ce3457cf145";

  fileSystems."/mnt/media2" =
    { device = "/dev/mapper/media2_crypt";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."media2_crypt".device = "/dev/disk/by-uuid/c942ef6a-79ce-4721-87f1-ccce3c7aed24";

  fileSystems."/mnt/cloud" =
    { device = "/dev/mapper/cloud_crypt";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."cloud_crypt".device = "/dev/disk/by-uuid/2ac03a3a-6974-4d85-9479-b4b45546e851";

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
