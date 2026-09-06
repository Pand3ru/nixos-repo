{ config, pkgs, lib, ... }:

let
  domain    = "music.panderu.org";
  musicDir  = "/mnt/media/music";
  inboxDir  = "/mnt/media/untracked";
  reviewDir = "/mnt/media/needs-review";
  beetsDir  = "/var/lib/beets";

  beetsPkg = pkgs.beets.override {
    pluginOverrides = {
      fetchart.enable   = true;
      embedart.enable   = true;
      lastgenre.enable  = true;
      chroma.enable     = true;
      scrub.enable      = true;
      replaygain.enable = true;
    };
  };

  beetsConfig = pkgs.writeText "beets-config.yaml" ''
    directory: ${musicDir}
    library: ${beetsDir}/library.db

    import:
      move: yes
      write: yes
      incremental: yes
      quiet: yes
      quiet_fallback: skip
      log: ${beetsDir}/import.log
      duplicate_action: skip

    paths:
      default: $albumartist/$album%aunique{}/$track $title
      singleton: Non-Album/$artist/$title
      comp: Compilations/$album%aunique{}/$track $title

    match:
      strong_rec_thresh: 0.10

    plugins: fetchart embedart lastgenre chroma scrub replaygain

    fetchart:
      auto: yes
    embedart:
      auto: yes
    lastgenre:
      auto: yes
    replaygain:
      backend: ffmpeg
      auto: yes
  '';

  importScript = pkgs.writeShellApplication {
    name = "beets-import";
    runtimeInputs = [ beetsPkg pkgs.ffmpeg pkgs.coreutils pkgs.findutils ];
    text = ''
      export BEETSDIR="${beetsDir}"

      if [ -z "$(ls -A "${inboxDir}" 2>/dev/null)" ]; then
        echo "Inbox empty, nothing to do."
        exit 0
      fi

      echo "Importing from ${inboxDir}"
      beet -c ${beetsConfig} import "${inboxDir}" || true

      if [ -n "$(ls -A "${inboxDir}" 2>/dev/null)" ]; then
        stamp="$(date +%Y%m%d-%H%M%S)"
        mkdir -p "${reviewDir}/$stamp"
        mv "${inboxDir}"/* "${reviewDir}/$stamp/"
        echo "Unmatched items moved to ${reviewDir}/$stamp"
      fi

      find "${inboxDir}" -mindepth 1 -type d -empty -delete || true

      chown -R navidrome:navidrome "${musicDir}"
      find "${musicDir}" -type d -exec chmod 755 {} +
      find "${musicDir}" -type f -exec chmod 644 {} +
    '';
  };
in
{
  services.navidrome = {
    enable = true;
    settings = {
      MusicFolder = musicDir;
      Address = "127.0.0.1";
      Port = 4533;
      ScanSchedule = "@every 1h";
      EnableInsightsCollector = false;
    };
  };

  services.caddy.virtualHosts."${domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:4533
  '';

  systemd.tmpfiles.rules = [
    "d ${musicDir}  0755 navidrome navidrome -"
    "d ${inboxDir}  0775 root      navidrome -"
    "d ${reviewDir} 0775 root      navidrome -"
    "d ${beetsDir}  0750 root      root      -"
  ];

  systemd.services.navidrome.unitConfig.RequiresMountsFor = [ musicDir ];

  systemd.timers.beets-import = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/15";
      Persistent = true;
      RandomizedDelaySec = "30s";
    };
  };

  systemd.services.beets-import = {
    description = "Beets import from inbox into Navidrome library";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    unitConfig.RequiresMountsFor = [ musicDir inboxDir ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe importScript;
      TimeoutStartSec = "6h";
      Nice = 10;
      IOSchedulingClass = "idle";
    };
  };
}
