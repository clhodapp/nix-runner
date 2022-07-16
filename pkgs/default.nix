{self, inputs}: final: prev:
let
  callScope = final.lib.makeScope final.newScope;
in {
  nix-runner = callScope (import ./nix-runner { inherit self inputs; });
}
