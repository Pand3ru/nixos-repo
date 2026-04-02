{ config, pkgs, userSettings, ... }:
let 
  updateURL = config.age.secrets.ddns-url.path;
in
{
  systemd.timers."ddns" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };
 
  systemd.services."ddns" = {
    path = [
      pkgs.curl
      pkgs.cacert
    ];
    serviceConfig = {
       Type = "oneshot";
       EnvironmentFile = updateURL;
       ExecStart = "${pkgs.curl}/bin/curl $DDNS_URL";
    };
  };
}
