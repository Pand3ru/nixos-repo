{ lib, stdenvNoCC, whitesur-icon-theme, gtk3 }:

let
  indexTheme = builtins.toFile "index.theme" ''
    [Icon Theme]
    Name=WhiteSur-Apps-dark
    Comment=WhiteSur application icons only; everything else falls back to Adwaita
    Inherits=Adwaita,hicolor
    Directories=apps/16,apps/22,apps/32,apps/scalable,apps/symbolic
    ScaledDirectories=apps@2x/16,apps@2x/22,apps@2x/32,apps@2x/scalable,apps@2x/symbolic

    [apps/16]
    Size=16
    Context=Applications
    Type=Fixed

    [apps/22]
    Size=22
    Context=Applications
    Type=Fixed

    [apps/32]
    Size=32
    Context=Applications
    Type=Fixed

    [apps/scalable]
    Size=64
    Context=Applications
    MinSize=16
    MaxSize=512
    Type=Scalable

    [apps/symbolic]
    Size=16
    Context=Applications
    MinSize=16
    MaxSize=512
    Type=Scalable

    [apps@2x/16]
    Size=16
    Scale=2
    Context=Applications
    Type=Fixed

    [apps@2x/22]
    Size=22
    Scale=2
    Context=Applications
    Type=Fixed

    [apps@2x/32]
    Size=32
    Scale=2
    Context=Applications
    Type=Fixed

    [apps@2x/scalable]
    Size=64
    Scale=2
    Context=Applications
    MinSize=16
    MaxSize=512
    Type=Scalable

    [apps@2x/symbolic]
    Size=16
    Scale=2
    Context=Applications
    MinSize=16
    MaxSize=512
    Type=Scalable
  '';
in
stdenvNoCC.mkDerivation {
  pname = "WhiteSur-apps-icon-theme";
  version = whitesur-icon-theme.version;

  dontUnpack = true;
  nativeBuildInputs = [ gtk3 ];

  installPhase = ''
    runHook preInstall

    # -L dereferences symlinks: WhiteSur's apps/ icons often alias into
    # other categories (e.g. actions/), which aren't copied into this theme.
    themeDir=$out/share/icons/WhiteSur-Apps-dark
    mkdir -p "$themeDir"
    cp -rL ${whitesur-icon-theme}/share/icons/WhiteSur-dark/apps "$themeDir"/apps
    cp -rL ${whitesur-icon-theme}/share/icons/WhiteSur-dark/apps@2x "$themeDir"/apps@2x
    cp ${indexTheme} "$themeDir"/index.theme

    gtk-update-icon-cache "$themeDir"

    runHook postInstall
  '';

  meta = {
    description = "WhiteSur icon theme, application icons only, falling back to Adwaita for everything else";
    license = whitesur-icon-theme.meta.license;
    platforms = whitesur-icon-theme.meta.platforms;
  };
}
