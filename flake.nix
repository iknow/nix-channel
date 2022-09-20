{
  description = "iKnow's shared nix utilities";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  inputs.branchctl = {
    url = "git+ssh://git@github.com/iknow/branchctl";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, branchctl }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      overlay = nixpkgs.lib.composeExtensions branchctl.overlay (import ./overlays/iknow.nix);
    in
  {
    inherit overlay;
    nixosModule = {
      imports = [ ./nixos-modules/all-modules.nix ];
      nixpkgs.overlays = [ overlay ];
    };
    darwinModule = {
      imports = [ ./darwin-modules/all-modules.nix ];
      nixpkgs.overlays = [ overlay ];
    };
  } // flake-utils.lib.eachSystem supportedSystems (system:
    let pkgs = nixpkgs.legacyPackages.${system}.extend overlay; in
    rec {
      packages = flake-utils.lib.flattenTree {
        inherit (pkgs)
          phraseapp_updater
          branchctl
          branchctlPlugins
          ;
      };
    }
  );
}
