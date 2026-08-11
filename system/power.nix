{ config, pkgs, lib, ... }:
{
  services.power-profiles-daemon.enable = true;

  # Only the Keychron keyboard (via the Ugreen USB-C hub) can wake the
  # machine from suspend. A blanket `SUBSYSTEM=="usb"` rule here previously
  # also enabled wakeup on internal devices (Bluetooth, fingerprint/touchpad,
  # SD card reader), any of which firing during suspend would wake the
  # machine right back up — draining the battery fast when suspended with
  # the lid closed and unplugged.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0340", ATTR{power/wakeup}="enabled"
  '';
}
