{ config, pkgs, ... }:
let
  nginxConf = pkgs.writeText "texlyre-nginx.conf" ''
    server {
      listen 80;
      server_name _;

      location /texlyre/ {
        alias /usr/share/nginx/html/;
        try_files $uri $uri/ /texlyre/index.html;
      }

      location = / {
        return 301 /texlyre/;
      }
    }
  '';
in
{
  services.caddy.virtualHosts."tex.panderu.org".extraConfig = ''
    handle_path /signaling* {
      reverse_proxy 127.0.0.1:8091
    }
    handle {
      reverse_proxy 127.0.0.1:8090
    }
  '';

  virtualisation.oci-containers.containers = {
    texlyre-frontend = {
      image = "ghcr.io/texlyre/texlyre-frontend:0.14.1";
      ports = [ "127.0.0.1:8090:80" ];
      volumes = [ "${nginxConf}:/etc/nginx/conf.d/default.conf:ro" ];
      environment = {
        SERVICES = "none";
        TEXLYRE_USERDATA = builtins.toJSON {
          settings."collab-signaling-servers" = "wss://tex.panderu.org/signaling";
        };
      };
      extraOptions = [ "--security-opt=no-new-privileges" ];
    };

    texlyre-signaling = {
      image = "ghcr.io/texlyre/y-webrtc-server:10.3.0";
      ports = [ "127.0.0.1:8091:1234" ];
      environment.PORT = "1234";
      extraOptions = [ "--security-opt=no-new-privileges" ];
    };
  };
}
