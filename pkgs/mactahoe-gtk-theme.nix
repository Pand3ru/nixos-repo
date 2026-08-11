{
  lib,
  stdenv,
  fetchFromGitHub,
  dialog,
  glib,
  gnome-themes-extra,
  jdupes,
  libxml2,
  sassc,
  util-linux,
}:

stdenv.mkDerivation {
  pname = "MacTahoe-gtk-theme";
  version = "2026-07-07";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "MacTahoe-gtk-theme";
    tag = "2026-07-07";
    hash = "sha256-XzvLVclV0My+2dq2+7CYBn9GsJy3BZzOBiqhjjiGv0M=";
  };

  nativeBuildInputs = [
    dialog
    glib
    jdupes
    libxml2
    sassc
    util-linux
  ];

  buildInputs = [
    gnome-themes-extra # adwaita engine for Gtk2
  ];

  postPatch = ''
    find -name "*.sh" -print0 | while IFS= read -r -d ''' file; do
      patchShebangs "$file"
    done

    # Do not provide `sudo`, as it is not needed in our use case of the install script
    substituteInPlace libs/lib-core.sh --replace-fail '$(which sudo)' false

    # Provides a dummy home directory
    substituteInPlace libs/lib-core.sh --replace-fail 'MY_HOME=$(getent passwd "''${MY_USERNAME}" | cut -d: -f6)' 'MY_HOME=/tmp'
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/themes

    ./install.sh --color dark --shell --dest $out/share/themes

    jdupes --quiet --link-soft --recurse $out/share

    runHook postInstall
  '';

  meta = {
    description = "macOS Tahoe like Gtk+ theme";
    homepage = "https://github.com/vinceliuice/MacTahoe-gtk-theme";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
