{
  stdenvNoCC,
  mdbook,
}:
stdenvNoCC.mkDerivation {
  pname = "wiki";
  version = "latest";
  src = ./.;
  buildInputs = [mdbook];
  buildPhase = ''
    mdbook build
  '';
  installPhase = ''
    mkdir -p $out/share
    cp -r book $out/share/web
  '';
}
