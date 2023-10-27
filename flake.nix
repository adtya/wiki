{
  description = "wiki.adtya.xyz";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
          packages.default = callPackage ./default.nix {};
        }
    );
}
