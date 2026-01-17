{
  description = "wiki.adtya.xyz";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils?ref=main";
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
        package = pkgs.callPackage ./default.nix { };
        app = pkgs.writeShellScriptBin "app" ''
          trap 'kill "''${child_pid}"; wait "''${child_pid}";' SIGINT SIGTERM
          ${pkgs.merecat}/bin/merecat -n -p 8080 ${package}/share/web &
          child_pid="$!"
          wait "''${child_pid}"
        '';
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.mdbook
          ];
        };
        packages = {
          inherit app;
          default = package;
        };
      }
    );
}
