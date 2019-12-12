self: super: {
  branch-server-ssh = super.callPackage ./branch-server-ssh {};

  phraseapp_updater = super.callPackage ./phraseapp_updater {};

  neovim-nightly = super.callPackage ./neovim-nightly.nix {};
}
