# Adhoc development environments with Nix

I've recently started exploring Python and Haskell. When working with projects in these, I need to have a bunch of dependencies installed. For example, with Python, I'd need a version of the Python interpreter itself, Pip of Pipenv or something similar for installing external modules, maybe a language server like pyright etc.

But I don't need these installed and available all the time, polluting my `$PATH`

## That's where Nix comes in.

[Nix](https://nixos.org/download#nix-install-linux) has a way to define development shells and activate them only when needed. When activated, it will update variables like `$PATH` and make any extra dependencies available. Once done working on something, it can be deactivated.

For example, below is a simple dev shell which installs `go 1.20`.
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
  in
  {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        pkgs.go_1_20
      ];
    };
  };
}
```
After creating a file called `flake.nix` in the project directory, it can be activated with the `nix develop` command. And once done, the shell can be closed with `exit` or <kbd>Ctrl+d</kbd>.

The problem with this is that, it starts a new `bash` shell with a really generic prompt. So any customizations made in `.bashrc` or `.zshrc` etc. gets lost.

## Direnv to the rescue

[Direnv](https://direnv.net/) is a tool that, once hooked up with the shell, will execute a set of commands mentioned in a per project `.envrc` file. It will execute these commands automatically when cd'd into the directory and the changes will be reverted when cd'ing out.

Direnv has something they call the [`stdlib`](https://github.com/direnv/direnv/blob/master/stdlib.sh), which is a set of sane defaults in the form of functions that can be put into the `envrc`. One such function is the `use_flake` function.

By creating a file called `.envrc` in the project directory with the content
```
use_flake
```
direnv will automatically append the environment created by the devShell defined in flake.nix to the existing shell env, without starting a new shell or losing any of the customizations from `.bashrc` or `.zshrc`


