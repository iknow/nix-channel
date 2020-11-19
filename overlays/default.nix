let
  branchCtlRepo = fetchGit { url = "git@github.com:iknow/branchctl"; ref = "master"; };
in
self: super: {
  phraseapp_updater = super.callPackage ./phraseapp_updater {};

  neovim-nightly = super.callPackage ./neovim-nightly.nix {};

  branchctl = self.callPackage "${branchCtlRepo}/nix/branchctl.nix" {};

  branchctlPlugins = {
    branchctl-secret-gpg = self.callPackage "${branchCtlRepo}/plugins/branchctl-secret-gpg" {};
  };
}
