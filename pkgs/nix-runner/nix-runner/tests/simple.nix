{
  runCommand,
  nix-runner
}:
runCommand "nix-runner-test-simple" {} ''

  nix-runner ${../../../../../tests/simple}

  mkdir $out
''
