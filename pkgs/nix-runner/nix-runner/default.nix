{
  bash,
  busybox,
  coreutils,
  flakeVersion,
  gnused,
  lib,
  dash,
  nixStatic,
  inputs,
  system,
  toybox,
  self
}:
let
  writeShellScriptBin = name: text: (
    builtins.derivation {
      inherit name system;
      text = ''
        #!${busybox}/bin/sh
        ${text}
      '';
      passAsFile = [ "text" ];
      builder = "${busybox}/bin/sh";
      args = [
        "-c"
        ''
          target=$out${lib.escapeShellArg "/bin/${name}"}
          ${busybox}/bin/mkdir -p "$(${busybox}/bin/dirname "$target")"
          if [ -e "$textPath" ]; then
            ${busybox}/bin/mv "$textPath" "$target"
          else
            echo -n "$text" > "$target"
          fi
          ${busybox}/bin/chmod +x "$target"
        ''
      ];
    }
  );

in
writeShellScriptBin "nix-runner" ''

  in_script="$1"

  shift

  exec -a "$in_script" \
    ${bash}/bin/sh <(
      ${busybox}/bin/sed \
        --quiet \
        --expression='1{s|^.*$|exec -a '"'$in_script'"' '"'${nixStatic}/bin/nix'"' shell --option experimental-features '"'nix-command flakes'"' \\|; p; d}' \
        --expression='/^#!pure[[:space:]]*$/{s/.*/  --unset "PATH" \\/; p; d}' \
        --expression='/^#!nix-option[[:space:]].*$/{s/^#!nix-option[[:space:]]*\(.*\) \(.*\)$/  --option '"'\1'"' '"'\2'"' \\/; p; d}' \
        --expression='/^#!registry[[:space:]].*$/{s/^#!registry[[:space:]]*\(.*\) \(.*\)$/  --override-flake '"'\1'"' '"'\2'"' \\/; p; d}' \
        --expression='/^#!package[[:space:]].*$/{s/^#!package[[:space:]]*\(.*\)$/  '"'\1'"' \\/; p; d}' \
        --expression='/^#!command[[:space:]].*$/{s/^#!command[[:space:]]*\(.*\)$/  --command '"'\1'"' \\/; p; d}' \
        "$in_script"

      echo '  "$@"'
    ) \
    "$in_script" "$@"
''
