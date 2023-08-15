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
          packages.image = dockerTools.buildImage {
            name = "wiki.adtya.xyz";
            tag = "latest";
            fromImage = dockerTools.pullImage {
              imageName = "nginx";
              imageDigest =
                if stdenv.isAarch64
                then "sha256:93e4bc3b0434bb3b6a7c0bb354aa78be9c23eb7d1853e329dde765e37f809d50"
                else "sha256:785ed82af07602663e62d36f462b1f9a212f0587de8737189fff9f258801d7c0";
              sha256 =
                if stdenv.isAarch64
                then "sha256-tFnQPV1SFU0sm2A+rV7xL9UAy7L2zbCzc/09Gu/BILU="
                else "sha256-J7lQrYyBtqim54u1mAGgw6cve1AJlvew4tg4jjMjkWg=";
              finalImageName = "nginx";
              finalImageTag = "stable-alpine-slim";
            };
            copyToRoot = callPackage ./default.nix {};
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
