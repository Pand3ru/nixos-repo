{ config, pkgs, lib, ... }:
let
  version = "1.15.0";
  dataDir = "/var/lib/aldine";
  network = "aldine-backend";

  # Container root -> unprivileged host uid, same for both since they share /data
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
    # Runs untrusted LaTeX
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
        TRUST_PROXY = "1";
        COOKIE_SECURE = "1";
      };
      environmentFiles = [ config.age.secrets.aldine.path ];
      extraOptions = [
        "--security-opt=no-new-privileges"
        "--init"
        # The internal network's DNS doesn't resolve outside names
        "--add-host=git.panderu.org:host-gateway"
      ] ++ idmap;
    };
  };
}
