let
  overlays = [
    (let
      src = builtins.fetchGit {
        url = "git@github.com:iknow/branchctl";
        ref = "master";
      };
    in import "${src}/nix/overlay.nix")
    (import ./packages.nix)
  ];
in
self: super:
with super.lib; (foldl' composeExtensions (self': super': {}) overlays) self super
