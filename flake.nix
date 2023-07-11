{
  description = "wiki.adtya.xyz";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
        with pkgs; {
          formatter = pkgs.alejandra;
          devShells.default = mkShell {
            buildInputs = [
              mdbook
            ];
          };
          packages.dockerImage = let
            book = callPackage ./default.nix {};
          in
            dockerTools.buildImage {
              name = "wiki.adtya.xyz";
              tag = "latest";
              fromImage = dockerTools.pullImage {
                imageName = "nginx";
                imageDigest =
                  if stdenv.isAarch64
                  then "sha256:9956d05e8f945ae928901c985936953e93eeb20f1b612b9851f8a5b02ba07b19"
                  else "sha256:da86ecb516d88a5b0579cec8687a75f974712cb5091560c06ef6c393ea4936ee";
                sha256 =
                  if stdenv.isAarch64
                  then "1mpy68r0vqkyb8ls2p8msarhsljjkv3pwvl23wbhipygjv1gmqa4"
                  else "003cpzhjn5myy7myw79gzy9x1mzb2h9b4q1jwwzlhhjv08db9bal";
                finalImageName = "nginx";
                finalImageTag = "alpine-slim";
              };
              copyToRoot = book;
              config = {
                Cmd = ["nginx" "-g" "daemon off;"];
                ExposedPort = {
                  "80/tcp" = {};
                };
              };
            };
        }
    );
}
