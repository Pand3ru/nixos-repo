{ config, lib, pkgs, userSettings, systemSettings, ...}:
{
  time.timeZone = systemSettings.timezone;

  i18n.defaultLocale = systemSettings.en-locale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = systemSettings.de-locale;
    LC_IDENTIFICATION = systemSettings.de-locale;
    LC_MEASUREMENT = systemSettings.de-locale;
    LC_MONETARY = systemSettings.de-locale;
    LC_NAME = systemSettings.de-locale;
    LC_NUMERIC = systemSettings.de-locale;
    LC_PAPER = systemSettings.de-locale;
    LC_TELEPHONE = systemSettings.de-locale;
    LC_TIME = systemSettings.de-locale;
    LC_CTYPE=systemSettings.en-locale;
  };
}
