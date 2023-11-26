{ stdenvNoCC
, mdbook
,
}:
stdenvNoCC.mkDerivation {
  pname = "wiki";
  version = "2023-11-26";
  src = ./.;
  buildInputs = [ mdbook ];
  buildPhase = ''
    mdbook build
  '';
  installPhase = ''
    mkdir -p $out/share
    cp -r book $out/share/web
  '';
}
