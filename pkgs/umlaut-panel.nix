# Local ZIP package; no uploads, remote source fetches, npm or compilation.
# Example call:
# pkgs.callPackage ./package.nix { extensionZip = /path/to/extension.zip; }
{ lib, stdenvNoCC, unzip, extensionZip, version ? "0.1.1" }:

let
  uuid = "umlaut-panel@local";
in
stdenvNoCC.mkDerivation {
  pname = "gnome-shell-extension-umlaut-panel";
  inherit version;
  src = extensionZip;

  dontUnpack = true;
  dontBuild = true;
  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    extensionDir="$out/share/gnome-shell/extensions/${uuid}"
    mkdir -p "$extensionDir"
    unzip -q "$src" -d "$extensionDir"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    extensionDir="$out/share/gnome-shell/extensions/${uuid}"
    test -f "$extensionDir/extension.js"
    test -f "$extensionDir/characters.js"
    test -f "$extensionDir/metadata.json"
    test -f "$extensionDir/stylesheet.css"
    test -f "$extensionDir/icons/reichstag-dome-symbolic.svg"

    runHook postInstallCheck
  '';

  passthru.extensionUuid = uuid;

  meta = {
    description = "Copy German umlauts and sharp s from the GNOME panel";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
