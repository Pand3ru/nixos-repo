{ config, pkgs, lib, ... }:
let
  version = "1.15.0";
  dataDir = "/var/lib/aldine";
  network = "aldine-backend";

  # Both images run as root inside; map that to an unprivileged host range. Both containers
  # need the same mapping since they share /data.
  idmap = [ "--uidmap=0:200000:65536" "--gidmap=0:200000:65536" ];
in
{
  services.caddy.virtualHosts."tex.panderu.org".extraConfig = ''
    reverse_proxy 127.0.0.1:8092
  '';

  systemd.tmpfiles.rules = [
    "d ${dataDir}/data 0750 200000 200000 -"
    "d ${dataDir}/secrets 0700 200000 200000 -"
  ];

  # The compiler sits only on this network, which has no route out
  systemd.services.podman-network-aldine = {
    description = "Podman network for Aldine";
    before = [ "podman-aldine-app.service" "podman-aldine-compiler.service" ];
    requiredBy = [ "podman-aldine-app.service" "podman-aldine-compiler.service" ];
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman network exists ${network} || podman network create --internal ${network}
    '';
  };

  virtualisation.oci-containers.containers = {
    # Runs untrusted LaTeX: no network egress, no capabilities, bounded memory and PIDs
    aldine-compiler = {
      image = "ghcr.io/trahloff/aldine-compiler:${version}";
      networks = [ network ];
      volumes = [ "${dataDir}/data:/data" ];
      environment = {
        DATA_DIR = "/data";
        MAX_CONCURRENT_COMPILES = "2";
      };
      extraOptions = [
        "--cap-drop=ALL"
        "--security-opt=no-new-privileges"
        "--memory=2g"
        "--pids-limit=256"
        "--init"
      ] ++ idmap;
    };

    aldine-app = {
      image = "ghcr.io/trahloff/aldine-app:${version}";
      networks = [ "podman" network ];
      ports = [ "127.0.0.1:8092:3000" ];
      volumes = [
        "${dataDir}/data:/data"
        "${dataDir}/secrets:/secrets"
      ];
      dependsOn = [ "aldine-compiler" ];
      environment = {
        DATA_DIR = "/data";
        META_DIR = "/secrets";
        COMPILER_URL = "http://aldine-compiler:4020";
        AUTH_ENABLED = "1";
        ALDINE_SIGNUP = "approval";
        ALDINE_PUBLIC_URL = "https://tex.panderu.org";
      };
      # ALDINE_ADMIN_EMAILS, optionally SMTP_*
      environmentFiles = [ config.age.secrets.aldine.path ];
      extraOptions = [
        "--security-opt=no-new-privileges"
        "--init"
      ] ++ idmap;
    };
  };
}
