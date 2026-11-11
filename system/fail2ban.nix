{ config, lib, pkgs, ... }:
let
  caddyLogs = config.services.caddy.logDir;
  dbFile = config.services.fail2ban.daemonSettings.Definition.dbfile;
  exporterPort = config.services.prometheus.exporters.fail2ban.port;

  # Written by public-ip.service, read by the ignorecommand on every hit
  ipv4File = "/run/public-ip";
  ipv6File = "/run/public-ipv6-prefix";

  # Same file names caddy.nix gives every vhost; explicit paths instead of a glob so the
  # rotated access-<host>-<timestamp>.log files aren't read again
  logpath = lib.concatStringsSep "\n          " (lib.mapAttrsToList
    (_: v: "${caddyLogs}/access-${lib.replaceStrings [ "/" " " ] [ "_" "_" ] v.hostName}.log")
    (lib.filterAttrs (_: v: v.logFormat != null) config.services.caddy.virtualHosts));

  # Paths none of the vhosts (cloud, vw, music, grafana, media/desk.home) serve; any request is a scanner.
  # Matched at the start of the URI, so /panderu/.env inside copyparty is not affected.
  # Regex syntax in Nix strings (\\. is a literal dot); a .git match ends in /, ? or the closing quote.
  badPaths = [
    "\\.env"
    "\\.git(?:/|\\?|\")"
    "wp-login\\.php"
    "wp-admin"
    "(?i:phpmyadmin)"
    "xmlrpc\\.php"
    "cgi-bin/"
  ];

  # Matched case-insensitively anywhere in the User-Agent. ffuf's default UA is "Fuzz Faster U Fool".
  badBots = [ "gobuster" "dirbuster" "ffuf" "Fuzz Faster U Fool" "nikto" "sqlmap" "nuclei" "wfuzz" "masscan" "zgrab" ];

  # Normalizes a public address: prints the IPv4 address resp. the IPv6 network it lives in
  # (prefix length from the local interface address, `ip -6 -o addr` on stdin, /64 otherwise).
  # Exits 1 for anything that isn't a valid global address of that family.
  normalize = pkgs.writeScript "public-ip-normalize" ''
    #!${pkgs.python3}/bin/python3
    import ipaddress
    import sys

    family, raw = int(sys.argv[1]), sys.argv[2].strip()
    try:
        addr = ipaddress.ip_address(raw)
    except ValueError:
        sys.exit(1)
    if addr.version != family or not addr.is_global:
        sys.exit(1)
    if family == 4:
        print(addr)
        sys.exit(0)

    for line in sys.stdin:
        for word in line.split():
            if "/" not in word:
                continue
            try:
                iface = ipaddress.ip_interface(word)
            except ValueError:
                continue
            if iface.version == 6 and addr in iface.network:
                print(iface.network)
                sys.exit(0)
    print(ipaddress.ip_network(str(addr) + "/64", strict=False))
  '';

  # Only overwrites a file on a plausible answer, otherwise the old value stays.
  # Always exits 0: a host without IPv6 must not trip the "unit failed" alert every 15 minutes.
  updatePublicIp = pkgs.writeShellScript "public-ip-update" ''
    set -u
    PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.curl pkgs.iproute2 ]}

    # Atomic replace, the ignore script must never read a half-written file
    write() {
      tmp=$(mktemp "$1.XXXXXX") || return 1
      if printf '%s\n' "$2" > "$tmp" && chmod 0644 "$tmp" && mv -f "$tmp" "$1"; then
        echo "$1: $2"
      else
        rm -f "$tmp"
      fi
    }

    fetch() {
      curl "-$1" -fsS --max-time 10 https://ifconfig.me
    }

    if ip4=$(fetch 4) && net=$(${normalize} 4 "$ip4" < /dev/null); then
      write ${ipv4File} "$net"
    else
      echo "No plausible IPv4 answer, keeping $(cat ${ipv4File} 2>/dev/null || echo nothing)"
    fi

    if ip6=$(fetch 6) && net=$(ip -6 -o addr show scope global | ${normalize} 6 "$ip6"); then
      write ${ipv6File} "$net"
    else
      echo "No plausible IPv6 answer, keeping $(cat ${ipv6File} 2>/dev/null || echo nothing)"
    fi
  '';

  # fail2ban ignorecommand: exit 0 = ignore <ip>, exit 1 = don't. Runs for every failure,
  # so it only reads the files above, no network. A missing or empty file means "don't ignore".
  ignorePublicIp = pkgs.writeShellScript "fail2ban-ignore-public-ip" ''
    case "''${1:-}" in
      "") exit 1 ;;
      *:*) file=${ipv6File} ;;
      *) file=${ipv4File} ;;
    esac
    [ -s "$file" ] || exit 1
    read -r net < "$file" || [ -n "''${net:-}" ] || exit 1
    if printf '%s\n' "$1" | ${pkgs.grepcidr}/bin/grepcidr -e "$net" > /dev/null 2>&1; then
      exit 0
    fi
    exit 1
  '';

  # Caddy's JSON access log line, fields in this order:
  #   {"level":"info","ts":1762862400.1234567,"logger":"http.log.access.log0","msg":"handled request",
  #    "request":{"remote_ip":..,"remote_port":..,"client_ip":..,"proto":..,"method":..,"host":..,"uri":..,
  #    "headers":{..},"tls":{..}},"bytes_read":..,"user_id":..,"duration":..,"size":..,"status":404,"resp_headers":{..}}
  # Caddy isn't behind a proxy/CDN, so client_ip == remote_ip; client_ip keeps it right should trusted_proxies
  # ever be set. Quotes inside JSON strings are escaped, so a URI or header can't fake an unescaped "client_ip":"…".
  # Header order inside "headers" is random (Go map), hence no assumptions there.
  caddyJail = { failregex, maxretry, findtime }: {
    filter.Definition = {
      inherit failregex;
      datepattern = ''"ts":{EPOCH}'';
    };
    settings = {
      inherit logpath maxretry findtime;
      # pyinotify notices Caddy's rename-based rotation (roll) and reopens the new file
      backend = "pyinotify";
      logencoding = "utf-8";
      bantime = -1;
      # One ipset per jail and family (f2b-<jail>, f2b-<jail>6), referenced by a single INPUT rule each:
      # stays fast however long the permanent list gets. All ports, all protocols.
      action = "iptables-ipset-proto6-allports[protocol=all]";
    };
  };
in
{
  services.fail2ban = {
    enable = true;
    # The firewall is iptables (networking.nftables is off), so ipset for the set-based actions
    extraPackages = [ pkgs.ipset ];

    # 127.0.0.1/8 and ::1 are added by the module. LAN and wireguard from dnsmasq.nix / wireguard.nix,
    # IPv6 ULA + link-local like the "internal" origin in traffic-logs.nix.
    # Not seen in the repo, add if needed: "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"
    ignoreIP = [
      "192.168.50.0/24"
      "10.0.0.0/24"
      "fc00::/7"
      "fe80::/10"
    ];

    # Bans with bantime -1 live in the `bips` table, which fail2ban never purges and restores on start.
    # dbpurgeage only trims the `bans` history table; -1 would not mean "never" here but delete
    # everything on the next purge (timeofban < now + 1), so a huge age instead.
    # dbfile stays at the module default /var/lib/fail2ban/fail2ban.sqlite3 (StateDirectory, persistent).
    daemonSettings.Definition.dbpurgeage = "100y";

    jails = {
      DEFAULT.settings = {
        ignoreself = true;
        ignorecommand = "${ignorePublicIp} <ip>";
        # Spares the fork per hit during a scan; an IP change takes at most 5 minutes to apply
        ignorecache = ''key="<ip>", max-count=1000, max-time=5m'';
      };

      # Directory brute forcing: lots of 401/403/404 from one IP. Bans are permanent, so the bar is high:
      # gobuster/ffuf send tens to hundreds of requests per second and cross 25 within the first second,
      # while a person hitting a broken page (missing favicon/source maps, a few 401s from an expired
      # Vaultwarden or Grafana session) stays well below 25 in a minute.
      #   match:    {"level":"info","ts":1762862400.12,"logger":"http.log.access.log0","msg":"handled request","request":{"remote_ip":"203.0.113.7","remote_port":"51234","client_ip":"203.0.113.7","proto":"HTTP/1.1","method":"GET","host":"cloud.panderu.org","uri":"/backup.zip","headers":{"User-Agent":["Mozilla/5.0"]}},"bytes_read":0,"user_id":"","duration":0.001,"size":0,"status":404,"resp_headers":{}}
      #   no match: {"level":"info","ts":1762862400.12,"logger":"http.log.access.log0","msg":"handled request","request":{"remote_ip":"203.0.113.7","remote_port":"51234","client_ip":"203.0.113.7","proto":"HTTP/1.1","method":"GET","host":"cloud.panderu.org","uri":"/","headers":{"User-Agent":["Mozilla/5.0"]}},"bytes_read":0,"user_id":"","duration":0.001,"size":512,"status":200,"resp_headers":{}}
      caddy-scan = caddyJail {
        failregex = ''"client_ip":"<ADDR>".*"status":40[134]\b'';
        maxretry = 25;
        findtime = 60;
      };

      # Scanner-only paths (list above), banned on the first request
      #   match:    {"level":"info","ts":1762862400.12,"logger":"http.log.access.log0","msg":"handled request","request":{"remote_ip":"203.0.113.7","remote_port":"51234","client_ip":"203.0.113.7","proto":"HTTP/1.1","method":"GET","host":"vw.panderu.org","uri":"/.env","headers":{"User-Agent":["curl/8.0"]}},"bytes_read":0,"user_id":"","duration":0.001,"size":0,"status":404,"resp_headers":{}}
      #   no match: {"level":"info","ts":1762862400.12,"logger":"http.log.access.log0","msg":"handled request","request":{"remote_ip":"203.0.113.7","remote_port":"51234","client_ip":"203.0.113.7","proto":"HTTP/1.1","method":"GET","host":"cloud.panderu.org","uri":"/panderu/.env","headers":{"User-Agent":["Mozilla/5.0"]}},"bytes_read":0,"user_id":"","duration":0.001,"size":0,"status":200,"resp_headers":{}}
      caddy-badpaths = caddyJail {
        failregex = ''"client_ip":"<ADDR>".*?"uri":"/(?:${lib.concatStringsSep "|" badPaths})'';
        maxretry = 1;
        findtime = 600;
      };

      # Scanner User-Agents (list above), banned on the first request
      #   match:    {"level":"info","ts":1762862400.12,"logger":"http.log.access.log0","msg":"handled request","request":{"remote_ip":"203.0.113.7","remote_port":"51234","client_ip":"203.0.113.7","proto":"HTTP/1.1","method":"GET","host":"music.panderu.org","uri":"/admin","headers":{"Accept":["*/*"],"User-Agent":["gobuster/3.6"]}},"bytes_read":0,"user_id":"","duration":0.001,"size":0,"status":404,"resp_headers":{}}
      #   no match: {"level":"info","ts":1762862400.12,"logger":"http.log.access.log0","msg":"handled request","request":{"remote_ip":"203.0.113.7","remote_port":"51234","client_ip":"203.0.113.7","proto":"HTTP/1.1","method":"GET","host":"music.panderu.org","uri":"/?q=nikto","headers":{"User-Agent":["Mozilla/5.0 (X11; Linux x86_64) Firefox/140.0"]}},"bytes_read":0,"user_id":"","duration":0.001,"size":512,"status":200,"resp_headers":{}}
      caddy-badbots = caddyJail {
        failregex = ''"client_ip":"<ADDR>".*"User-Agent":\["(?:[^"\\]|\\.)*?(?i:${lib.concatStringsSep "|" badBots})'';
        maxretry = 1;
        findtime = 600;
      };
    };
  };

  # Caddy opens its log files on start; a jail whose files don't exist yet would skip them
  systemd.services.fail2ban.after = [ "caddy.service" ];

  # Public IPv4 and IPv6 prefix for the ignorecommand. /run is empty after boot, so the first run is early.
  systemd.timers.public-ip = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "15min";
    };
  };

  systemd.services.public-ip = {
    description = "Write the public IPv4 and IPv6 prefix to /run";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = updatePublicIp;
      CapabilityBoundingSet = [ "" ];
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ReadWritePaths = [ "/run" ];
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectClock = true;
      ProtectHostname = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      SystemCallArchitectures = "native";
    };
  };

  # Exporter on localhost only, no firewall port. The module's setup unit grants the exporter user
  # an ACL on the fail2ban socket; fail2ban has no read-only socket, so that's the minimum it can get.
  services.prometheus.exporters.fail2ban = {
    enable = true;
    host = "127.0.0.1";
  };

  systemd.services.prometheus-fail2ban-exporter.serviceConfig = {
    IPAddressDeny = "any";
    IPAddressAllow = "localhost";
    ProtectProc = "invisible";
    ProcSubset = "pid";
    SystemCallFilter = [ "@system-service" "~@privileged" ];
    SystemCallErrorNumber = "EPERM";
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "fail2ban";
      static_configs = [ { targets = [ "127.0.0.1:${toString exporterPort}" ]; } ];
    }
  ];

  # Ban/Unban lines from the journal to Loki for the "events in range" table on the Caddy dashboard.
  # Alloy reads every *.alloy in /etc/alloy as one config, so loki.write.local from traffic-logs.nix is shared.
  # The per-hit "Found" lines are dropped, they stay in the journal only.
  environment.etc."alloy/fail2ban.alloy".text = ''
    loki.source.journal "fail2ban" {
      matches    = "_SYSTEMD_UNIT=fail2ban.service"
      forward_to = [loki.process.fail2ban.receiver]
      labels     = {
        job      = "fail2ban",
        instance = "${config.networking.hostName}",
      }
    }

    loki.process "fail2ban" {
      stage.match {
        selector = `{job="fail2ban"} !~ "\\] (Restore )?(Ban|Unban) "`
        action   = "drop"
      }

      stage.regex {
        expression = `\[(?P<jail>[^\]]+)\]\s+(?P<action>Restore Ban|Ban|Unban)\s+(?P<ip>\S+)`
      }

      stage.labels {
        values = {
          jail   = "",
          action = "",
        }
      }

      stage.structured_metadata {
        values = {
          ip = "",
        }
      }

      forward_to = [loki.write.local.receiver]
    }
  '';

  # Full list of active bans straight from the fail2ban database (Caddy dashboard, row "fail2ban")
  services.grafana.declarativePlugins = with pkgs.grafanaPlugins; [ frser-sqlite-datasource ];

  services.grafana.provision.datasources.settings.datasources = [
    {
      name = "fail2ban";
      type = "frser-sqlite-datasource";
      uid = "fail2ban-db";
      editable = false;
      # The plugin adds _pragma=query_only(1) on top
      jsonData = {
        path = dbFile;
        pathPrefix = "file:";
        pathOptions = "mode=ro";
      };
    }
  ];

  # /var/lib/fail2ban is 0750 root. Grafana gets traverse on the directory and read on the db file
  # via ACL, nothing else changes for fail2ban. The ACL survives fail2ban restarts (systemd only chmods).
  systemd.services.grafana-fail2ban-db-access = {
    description = "Let Grafana read the fail2ban database";
    after = [ "fail2ban.service" ];
    wants = [ "fail2ban.service" ];
    before = [ "grafana.service" ];
    wantedBy = [ "grafana.service" ];
    path = [ pkgs.acl pkgs.coreutils ];
    script = ''
      # fail2ban creates the db on its first start
      for _ in $(seq 60); do
        [ -e ${dbFile} ] && break
        sleep 1
      done

      setfacl -m u:grafana:x ${dirOf dbFile}
      setfacl -m u:grafana:r ${dbFile}
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
