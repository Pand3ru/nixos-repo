{ config, pkgs, ... }:
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    dataDir = "/var/lib/jellyfin";
  };

  services.caddy.virtualHosts."http://media.home".bookmark = "Jellyfin";
  services.caddy.virtualHosts."http://media.home".extraConfig = ''
    reverse_proxy 127.0.0.1:8096
  '';

  # Debug tools only: vainfo, intel_gpu_top, clinfo
  environment.systemPackages = with pkgs; [
    libva-utils
    intel-gpu-tools
    clinfo
  ];

  # i7-7700T / HD 630 (Kaby Lake, Gen 9.5): use VAAPI in Jellyfin, not QSV.
  # intel-media-sdk is EOL and vpl-gpu-rt needs Gen12+.
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime-legacy1 # OpenCL for HDR tone mapping (regular intel-compute-runtime is Gen12+ only)
    ];
  };

  systemd.services.jellyfin = {
    environment = {
      LIBVA_DRIVER_NAME = "iHD";
    };

    serviceConfig = {
      DeviceAllow = [
        "/dev/dri rw"
        "/dev/dri/card0 rw"
        "/dev/dri/renderD128 rw"
      ];
      SupplementaryGroups = [ "video" "render" ];
      MemoryMax = "32G";
      CPUQuota = "800%";
      LimitNOFILE = 65536;
    };
  };

  boot.kernelModules = [ "i915" ];
  # Kaby Lake needs HuC loaded for the low-power H.264 encoder
  boot.kernelParams = [ "i915.enable_guc=2" ];
}
