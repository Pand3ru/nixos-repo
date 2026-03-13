{ config, pkgs, ... }:

let
  mpvConfig = ''
    vo=gpu-next
    gpu-api=opengl
    
    hwdec=vaapi
    hwdec-vaapi-driver=iHD
    
    cache=yes
    demuxer-max-bytes=1GiB
    demuxer-max-back-bytes=512MiB
    
    tone-mapping=hable
    hdr-compute-peak=yes
    target-prim=bt.709
    target-trc=bt.1886
    
    video-sync=display-resample
    scale=bicubic
    cscale=bicubic
  '';
in

{
  programs.mpv.enable = true;

  programs.mpv.package = pkgs.mpv;

  programs.mpv.config = {
    extras = mpvConfig;
  };
}
