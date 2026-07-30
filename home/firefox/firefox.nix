{ config, pkgs, userSettings, systemSettings, bookmarks, ...}:
let
    mozillaAddon = "https://addons.mozilla.org/firefox/downloads/latest";

    lock-empty-string = { Value = ""; Status = "locked"; };
    lock-false = { Value = false; Status = "locked"; };
    lock-true = { Value = true; Status = "locked"; };
    lock = value: { Value = value; Status = "locked"; };
in
{
programs.firefox = {
  enable = true;

  profiles.${userSettings.username} = {
    search = import ./search.nix;

    bookmarks = {
      force = true;
      settings = [ (import ./bookmarks.nix) ];
    };

    # catppuccin.nix's Firefox module writes the Firefox Color theme via
    # profiles.<name>.extensions.settings, which requires this ack since it
    # would otherwise silently replace the whole extensions.settings set.
    extensions.force = true;

    isDefault = true;

    settings = {
      "signon.rememberSignons" = false;
      "widget.use-xdg-desktop-portal.file-picker" = 1;
      "browser.aboutConfig.showWarning" = false;
      "browser.compactmode.show" = true;
      "browser.cache.disk.enable" = false; # Be kind to hard drive

      "extensions.pocket.enabled" = lock-false;
      "browser.newtabpage.pinned" = lock-empty-string;
      "browser.topsites.contile.enabled" = lock-false;
      "browser.toolbars.bookmarks.visibility" = "always";
      "browser.newtabpage.activity-stream.showSponsored" = lock-false;
      "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
      "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;

      "browser.startup.homepage" = "previous-session";

      "dom.security.https_only_mode" = true;
      "browser.download.panel.shown" = true;
      "browser.sessionstore.resume_session_once" = true;

      "privacy.globalprivacycontrol.enabled" = true;
      "privacy.donottrackheader.enabled" = true;
      "privacy.trackingprotection.enabled" = true;
      "privacy.trackingprotection.socialtracking.enabled" = true;
      "privacy.partition.network_state.ocsp_cache" = true;
    };
  };

  policies = {
    DisableTelemetry = true;
    DisableFirefoxStudies = true;
    DisablePocket = true;
    DontCheckDefaultBrowser = true;

    EnableTrackingProtection = {
      Value = true;
      Locked = true;
      Cryptomining = true;
      Fingerprinting = true;
    };

    Cookies = {
      Behavior = "reject-tracker-and-partition-foreign";
    };

    DisableFeedbackCommands = true;
    DisableFirefoxAccounts = true; 

    ExtensionSettings = {
      "uBlock0@raymondhill.net" = {
        install_url = "${mozillaAddon}/ublock-origin/latest.xpi";
        installation_mode = "force_installed";
      };
      "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
        install_url = "${mozillaAddon}/bitwarden-password-manager/latest.xpi";
        installation_mode = "force_installed";
      };
      "jid1-MnnxcxisBPnSXQ@jetpack" = {
        install_url = "${mozillaAddon}/privacy-badger17/latest.xpi";
        installation_mode = "force_installed";
      };
      "addon@darkreader.org" = {
         install_url = "${mozillaAddon}/darkreader/latest.xpi";
         installation_mode = "force_installed";
      };

      "sponsorBlocker@ajay.app" = {
        install_url = "${mozillaAddon}/sponsorblock/latest.xpi";
        installation_mode = "force_installed";
      };

      "{74145f27-f039-47ce-a470-a662b129930a}" = {
        install_url = "${mozillaAddon}/clearurls/latest.xpi";
        installation_mode = "force_installed";
      };

      "myallychou@gmail.com" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/file/4263531/youtube_recommended_videos-1.6.7.xpi";
        installation_mode = "force_installed";
      };


      "extension@tabliss.io" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/file/3940751/tabliss-2.6.0.xpi";
        installation_mode = "force_installed";
      };
      "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/file/4618554/vimium_ff-2.3.1.xpi";
        installation_mode = "force_installed";
      };
      "jid1-sirVJT0BXhkuJg@jetpack" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/file/3853490/premiumizeme-1.0.22.xpi";
        installation_mode = "force_installed";
      };
      "{20fc2e06-e3e4-4b2b-812b-ab431220cada}" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/file/4416483/startpage_private_search-2.0.3.xpi";
        installation_mode = "force_installed";
       };
      "zotero@chnm.gmu.edu" = {
        install_url = "https://www.zotero.org/download/connector/dl?browser=firefox&version=5.0.199";
        installation_mode = "force_installed";
        };
      };
    };
  };
}
