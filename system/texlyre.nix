{ config, pkgs, ... }:
let
  # Same as texlyre-infrastructure's nginx/default.conf: the app lives under
  # /texlyre/ and / redirects there.
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
  # Collaborative LaTeX/Typst editor. Compiling happens in the browser (WASM)
  # and projects live there too; the server only hands out the static app and
  # introduces peers to each other. Access is by project share link, backups
  # go to a Forgejo repo (forgejo.nix). TeX package and FilePizza servers are
  # left on TeXlyre's public defaults.
  services.caddy.virtualHosts."tex.panderu.org".bookmark = "TeXlyre";
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
        # Don't add the infrastructure repo's endpoint layers; only the
        # signaling server below is self-hosted.
        SERVICES = "none";
        TEXLYRE_USERDATA = builtins.toJSON {
          settings."collab-signaling-servers" = "wss://tex.panderu.org/signaling";
        };
      };
      extraOptions = [ "--security-opt=no-new-privileges" ];
    };

    # y-webrtc signaling: only relays connection setup, never document content
    texlyre-signaling = {
      image = "ghcr.io/texlyre/y-webrtc-server:10.3.0";
      ports = [ "127.0.0.1:8091:1234" ];
      environment.PORT = "1234";
      extraOptions = [ "--security-opt=no-new-privileges" ];
    };
  };
}
