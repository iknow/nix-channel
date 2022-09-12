# Re-export the overlay from branchctl for convenience
let
  branchctl = fetchGit { url = "git@github.com:iknow/branchctl"; ref = "master"; };
in
  import "${branchctl}/nix/overlay-with-rev.nix" { rev = branchctl.rev or "unknown"; }
