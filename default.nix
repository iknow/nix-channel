let
  packagesWithOverlay = import <nixpkgs> {
    overlays = [ (import ./overlays) ];
  };
in
{
  inherit (packagesWithOverlay)
    branch-server-ssh
    lorri
    phraseapp_updater
    neovim-nightly
    branchctl
    ;
}
