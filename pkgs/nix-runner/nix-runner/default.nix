{
  autoreconfHook,
  bash,
  callPackage,
  coreutils,
  flakeVersion,
  gnused,
  lib,
  nix,
  resholve,
  which,
  writeShellScript,
  self
}:
(
  resholve.mkDerivation {
    pname = "nix-runner";
    version = flakeVersion;
    nativeBuildInputs = [ autoreconfHook ];
    src = ../../../src;
    solutions = {
      nix-runner = let
        inputs = [ bash coreutils gnused nix resholve which ];
      in {
        inherit inputs;
        scripts = [ "bin/nix-runner" ];
        interpreter = "${bash}/bin/bash";
        fix = {
          "$NIX" = ["${nix}/bin/nix"];
        };
        execer = [
          "cannot:${nix}/bin/nix"
          "cannot:${resholve}/bin/resholve"
        ];
      };
    };
  }
).overrideAttrs (finalAttrs: previousAttrs: {
  pname = "nix-runner";
  passThru = {
    tests = {
      simple = callPackage ./tests/simple.nix {};
    };
  };
  meta = {
    mainProgram = "nix-runner";
  };
})
