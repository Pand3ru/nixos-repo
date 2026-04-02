{ config, lib, pkgs, inputs, ... }:
let
  copyparty = inputs.copyparty;
  panderu-pw = config.age.secrets.copyparty-panderu.path;
  other-pw = config.age.secrets.copyparty-other.path;
in 
{
  imports = [
    copyparty.nixosModules.default
  ];

  services.caddy.virtualHosts."cloud.panderu.org".extraConfig = ''
    reverse_proxy 127.0.0.1:3923
  '';

  # Add the copyparty overlay to expose the package
  nixpkgs.overlays = [ copyparty.overlays.default ];

  environment.systemPackages = [ pkgs.copyparty ];

  # Enable and configure copyparty service
  services.copyparty = {
    enable = true;

     settings = {
       i = "127.0.0.1";
       p = [ 3923 ];
       no-reload= true;
       chpw = true; # change passwords
       qr = true;
       qrs = true;
       e2dsa = true;
       e2ts = true;
       dedup = true;
       z = true;
       shr = "/shr";
       xff-src="lan";
       xff-hdr = "x-forwarded-for";
       rproxy = 1;
       dav-auth = true;
       j = 4;
       s-thead = 2;
       no-thumb = false;
       unpost = 3600;
       hardlink = true;
     };

     accounts = {
       panderoot = {
         passwordFile = panderu-pw;
       };

       meowsi = {
         passwordFile = other-pw;
       };
     };

     volumes = {
       "/panderu" = {
         path = "/mnt/cloud/panderu";
         access.rwmda = [ "panderoot" ];
         access.g = "*";
         flags = {
           fk = 8;
           e2d = true;
         };
       };

       "/meoswi" = {
         path = "/mnt/cloud/meowsi";
         access.rwmda = [ "meowsi" "panderoot" ];
         access.g = "*";
         flags = {
           fk = 8;
           e2d = true;
         };
       };

       "/uploads" = {
          path = "/mnt/cloud/uploads";
          access.rwmda = [ "panderoot" "meowsi" ];
          access.g = "*";
          flags = {
           fk = 8;
           e2d = true;
         };
       };
     };

     openFilesLimit = 8192;
  };
}
