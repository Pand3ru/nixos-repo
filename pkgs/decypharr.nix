{ lib, buildGoModule, fetchFromGitHub, rclone, makeWrapper }:

buildGoModule {
  pname = "decypharr";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "sirrobot01";
    repo = "decypharr";
    rev = "207d43b13ff429f8e079babdf29302a580122b8e";
    hash = "sha256-flMkge2eeVM+MVQGlTdvuVUqMHFBSMoFUpxD2Sp6ZxQ=";
  };

  vendorHash = "sha256-PXvIxXuX/u28Ndhg4aEMly2KSgMP31vIR0WINEoHVHk";

  doCheck = false;

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/decypharr \
      --prefix PATH : ${lib.makeBinPath [ rclone ]}
  '';

  meta = {
    description = "Debrid media manager";
    homepage = "https://github.com/sirrobot01/decypharr";
    mainProgram = "decypharr";
  };
}
