self: super: {
  branch-server-ssh = super.callPackage ./branch-server-ssh {};

  phraseapp_updater = super.callPackage ./phraseapp_updater {};

  neovim-nightly = super.callPackage ./neovim-nightly.nix {};

  branchctl = let
    src = builtins.fetchGit {
      url = "git@github.com:iknow/branchctl";
      ref = "master";
    };
  in super.callPackage "${src}/nix/branchctl.nix" {};
}
