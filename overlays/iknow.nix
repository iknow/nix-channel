# The pure overlay for packages local to this repo (iknow/nix-channel)
final: prev: {
  phraseapp_updater = final.callPackage ./phraseapp_updater {};

  inherit (final.callPackage ./yarn {}) yarn-iknow berry2nix;

  dprintForConfig = dprintJson: final.callPackage ./dprint.nix { inherit dprintJson; };
}
