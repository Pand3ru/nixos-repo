{ config, pkgs, ... }:
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    dataDir = "/var/lib/jellyfin";
  };
  
  users.users."jellyfin".extraGroups = [ "radarr" "sonarr" ];

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    intel-media-driver
    ocl-icd
    clinfo
    libvdpau-va-gl
    libva-utils
    intel-gpu-tools
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  systemd.services.jellyfin = {
    environment = {
      LIBVA_DRIVER_NAME = "iHD";
      OCL_ICD_VENDORS = "/etc/OpenCL/vendors";
    };

    serviceConfig = {
      DeviceAllow = [
        "/dev/dri rw"
      ];
      SupplementaryGroups = [ "video" "render" ];
      MemoryMax = "32G";
      CPUQuota = "800%";
      LimitNOFILE = 65536;
    };
  };

  boot.kernelModules = [ "i915" ];
  boot.kernelParams = [ "i915.enable_guc=2" ];
}
