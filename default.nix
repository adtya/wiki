{ stdenvNoCC
, mdbook
, mdbook-alerts
,
}:
stdenvNoCC.mkDerivation {
  pname = "wiki";
  version = "2024-07-02";
  src = ./.;
  buildInputs = [ mdbook mdbook-alerts ];
  buildPhase = ''
    mdbook build
  '';
  installPhase = ''
    mkdir -p $out/share
    cp -r book $out/share/web
  '';
}
