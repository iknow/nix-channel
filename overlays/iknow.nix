# The pure overlay for packages local to this repo (iknow/nix-channel)
final: prev: {
  phraseapp_updater = final.callPackage ./phraseapp_updater {};
}
