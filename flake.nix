{

  description = "Nix shell shebang utility";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";

  outputs = { self, flake-utils, nix, nixpkgs, ...}@inputs: (
    flake-utils.lib.eachSystem (flake-utils.lib.allSystems) (system:
      let
        pkgs = import nixpkgs {
          overlays = builtins.attrValues self.overlays;
          inherit system;
        };
      in rec {

        devShells = {
          default = (
            pkgs.mkShell {
              nativeBuildInputs = [
                pkgs.bash
                pkgs.nix
                pkgs.git
              ];
            }
          );
        };

        apps = rec {
          default = nix-runner;
          nix-runner = {
            type = "app";
            program = "${packages.nix-runner}/bin/nix-runner";
          };
        };

        packages = nixpkgs.lib.filterAttrs (n: v: nixpkgs.lib.isDerivation v) pkgs.nix-runner;

      }
    ) // {

      overlays = {
        packages = import ./pkgs { inherit self inputs; };
      };

    }
  );

}
