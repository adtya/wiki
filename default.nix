{ stdenvNoCC
, mdbook
, mdbook-alerts
,
}:
stdenvNoCC.mkDerivation {
  pname = "wiki";
  version = "2023-12-04";
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
