
# nix-runner
> Tidy shell shebangs with nix flakes

## About
nix-runner is a tool for writing shell scripts that behave predictably on any machine that has the `nix` package manager installed. It allows you to precisely specify your
dependencies with magic comments at the top of your script and leverages `nix shell` to run your script with them on your `PATH`. Facility is made for allowing you to specify
script-local registry pins, which allows you to pull all of your dependencies from a specific version of nixpkgs (and update the pin in a single place). It was written due
to impatience in waiting for https://github.com/NixOS/nix/pull/5189 or a similar feature to land in `nix` proper.

## Usage

It is recommended that you use `nix run` to invoke a pinned version of the `nix-runner` command, based on a commit hash. This should make your scripts behave predicatably even
if the default behavior of nix-runner changes in a subsequent version, which is somewhat likely to happen. Internally, the `nix-runner` command will perform another invocation
of `nix shell` with its own internally-pinned version of the `nix` command.

### Example

```shell
#!/usr/bin/env -S nix run 'github:clhodapp/nix-runner/7b56158f7ab9fd7806068c6571833210e063df19'
#!pure
#!registry nixpkgs github:NixOS/nixpkgs/5f862a767195f5183b2aca3618b45b9a8d1ed9d6
#!package nixpkgs#bash
#!package nixpkgs#coreutils
#!package nixpkgs#jq
#!package nixpkgs#nix
#!command bash

readonly temp_file=$(mktemp)

echo '{"city": "San Francisco", "state": "CA"}' > "${temp_file}"

jq '.state' "${temp_file}"

```

## Magic comments (reference)
nix-runner magic comments are consecutive lines starting with `#!`, from the second line of the script. A current limitation is that magic comments must be grouped by type and
specified in a particular order. For convenience, the order in this README will match the order that the magic comments need to be in.

### `#!pure` (optional, once)
Unset the existing `$PATH`, resulting in the specified dependencies being the only thing on the `$PATH` when the script runs. Highly recommended if you want to make your script
more machine-independent.

### `#!registry <original-ref> <resolved-ref>` (optional, repeated)
Define a script-local nix registry. This is most useful to allow you to share a single pin across many packages (e.g. pin a specific `nixpkgs` hash that you can update in one
place).

### `#!package <installable>` (optional, repeated)
Specify a package that you want to put on your `$PATH` when your script runs, specified as flake installable. You can (are encouraged to!) leverage registries specified with
`#!registry` to achieve predictable versioning, though you are completely free to e.g. track an unstable branch of `nixpkgs` dynamically. It is highly recommended that you
include the script runner (e.g. bash) in the list of specified packages, as it allows you to take control of the version that will be used to run your script.

### `#!command <command>` (required, once)
Specify the name of the shell you want to use to run your script. It is expected that `<command>` will be a simple command name (e.g. `bash`), which will be looked up on the
`$PATH` that the `nix-runner` command sets up. Although nix-runner is intended to be used to run shell scripts, it should be technically possible to use it with any runner
command that is packaged for nix and uses `#` as its comment character.

## Implementation note

At present, the `nix-runner` command is itself a simple shell script, which uses `sed` to process magic comments. This approach is kind of hacky, doesn't allow for good
error messages, and creates the limitation on the ordering described above. In the future, it's possible that it will be rewritten in a general-purpose
language to resolve these limitations.
