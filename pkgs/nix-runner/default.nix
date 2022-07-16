{self, inputs}: nixpkgs:
let
  inherit (nixpkgs) callPackage;
in rec {
  inherit self inputs;
  flakeVersion = (
    if (self ? lastModifiedDate && self ? rev) # Check rev to see if we are on a clean commit
    then (
      let
        year = builtins.substring 0 4 self.lastModifiedDate;
        month = builtins.substring 4 2 self.lastModifiedDate;
        day = builtins.substring 6 2 self.lastModifiedDate;
      in "unstable-${year}-${month}-${day}"
    )
    else "dirty"
  );
  default = nix-runner;
  nix-runner = callPackage ./nix-runner { };
}
