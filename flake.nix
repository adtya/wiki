{
  description = "wiki.adtya.xyz";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    ,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      with pkgs; {
        formatter = nixpkgs-fmt;
        devShells.default = mkShell {
          packages = [
            mdbook
            tailwindcss-language-server
          ];
        };
        packages.default = callPackage ./default.nix { };
      }
    );
}
