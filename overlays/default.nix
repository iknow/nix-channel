# Convenience overlay for non-flake systems
#
# Systems using flakes should use the "overlay" flake output, which is
# this composition but with a flake input instead of "fetchGit".

final: prev: prev.lib.composeExtensions (import ./branchctl.nix) (import ./iknow.nix) final prev
