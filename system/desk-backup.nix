{ config, lib, pkgs, ... }:
let
  # The desks keep their settings in their own flash (they have to work without the server),
  # this only snapshots them hourly so a wiped or replaced board can be set up again
  desks = config.desk.desks;
  dir = "/var/lib/desk";

  backup = pkgs.writeShellApplication {
    name = "desk-backup";
    runtimeInputs = [ pkgs.curl pkgs.jq pkgs.diffutils ];
    text = ''
      fetch() { curl -fsS -m 10 --retry 2 "http://$1$2"; }

      save() {
        local host=$1 ip=$2 s p c out="${dir}/$1.json"
        # Desks are off at night: keep the last snapshot, don't fail the unit
        if ! { s=$(fetch "$ip" /settings) && p=$(fetch "$ip" /profiles) && c=$(fetch "$ip" /config); }; then
          echo "$host: not reachable, keeping last snapshot"
          return 0
        fi
        # currentMm changes all the time and isn't a setting
        jq -n --argjson settings "$s" --argjson profiles "$p" --argjson config "$c" \
          '{ settings: $settings, profiles: $profiles, config: ($config | del(.currentMm)) }' > "$out.tmp"
        if cmp -s "$out.tmp" "$out"; then
          rm "$out.tmp"
        else
          mv "$out.tmp" "$out"
          echo "$host: saved"
        fi
      }

      ${lib.concatMapStrings (d: ''
        save ${lib.escapeShellArgs [ d.host d.ip ]}
      '') desks}
    '';
  };

  restore = pkgs.writeShellApplication {
    name = "desk-restore";
    runtimeInputs = [ pkgs.curl pkgs.jq ];
    text = ''
      usage() { echo "usage: desk-restore <host> [snapshot.json]" >&2; exit 1; }
      [ $# -ge 1 ] || usage
      host=$1
      file=''${2:-${dir}/$host.json}
      case "$host" in
        ${lib.concatMapStrings (d: ''
          ${lib.escapeShellArg d.host}) ip=${lib.escapeShellArg d.ip} ;;
        '') desks}
        *) echo "unknown desk: $host (known: ${lib.concatMapStringsSep ", " (d: d.host) desks})" >&2; exit 1 ;;
      esac
      [ -r "$file" ] || { echo "no snapshot at $file" >&2; exit 1; }

      echo "Restoring $file to $host ($ip). The hostname is not touched."
      jq . "$file"
      read -r -p "Continue? [y/N] " ok
      [ "$ok" = y ] || exit 1

      post() { curl -fsS -m 10 -X POST "http://$ip$1" > /dev/null && echo "ok  $1"; }

      jq -r '.profiles.profiles[] | "/profile/save?id=\(.id)&name=\(.name | @uri)&mm=\(.mm)"' "$file" \
        | while read -r q; do post "$q"; done
      jq -r '.profiles.buttons | to_entries[] | "/profile/assign?button=\(.key + 1)&id=\(.value)"' "$file" \
        | while read -r q; do post "$q"; done
      post "$(jq -r '.profiles.auto | "/profile/auto?a=\(.[0])&b=\(.[1])"' "$file")"
      post "$(jq -r '.settings | "/settings?regularEnd=\(.regularEnd)&autoEnabled=\(if .autoEnabled then 1 else 0 end)&interval=\(.interval)&lockMin=\(.lockMin)"' "$file")"
      # /config takes total run times over a distance; 1000 mm turns ms/mm back into totals
      post "$(jq -r '.config | "/config?upMs=\(.upMsPerMm * 1000)&downMs=\(.downMsPerMm * 1000)&travelMm=1000"' "$file")"
    '';
  };
in
{
  environment.systemPackages = [ restore ];

  systemd.services.desk-backup = {
    description = "Snapshot standing desk settings";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe backup;
      StateDirectory = "desk";
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };

  systemd.timers.desk-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };

  restic.paths = [ dir ];
}
