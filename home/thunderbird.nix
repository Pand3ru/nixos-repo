{ config, pkgs, systemSettings, userSettings, ... }:
{
  programs.thunderbird = {
    enable = true;

    profiles.${userSettings.username} = {
        isDefault = true;
    };

    settings = {
      "privacy.donottrackheader.enabled" = true;
       "privacy.fingerprintingProtection" = true;
      "privacy.resistFingerprinting" = true;
      "intl.accept_languages" = "en-US, en, de";
      "spellchecker.dictionary" = "en-US, en, de";
    };
  };
}
