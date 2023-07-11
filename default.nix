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
    mkdir -p $out/share/nginx
    cp -r book $out/share/nginx/html
    mkdir -p $out/etc/nginx/conf.d
    cp nginx.conf $out/etc/nginx/conf.d/default.conf
    sed -i "s@/usr@$out@" $out/etc/nginx/conf.d/default.conf
  '';
}
