let
  packagesWithOverlay = import <nixpkgs> {
    overlays = [ (import ./overlays/packages.nix) ];
  };
in
{
  inherit (packagesWithOverlay)
    branch-server-ssh
    lorri
    phraseapp_updater
    neovim-nightly
    ;
}
