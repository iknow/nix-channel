let
  packagesWithOverlay = import <nixpkgs> {
    overlays = [ (import ./overlays) ];
  };
in
{
  inherit (packagesWithOverlay)
    phraseapp_updater
    neovim-nightly
    branchctl
    ;
}
