{
  description = "CI Example";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nix-utils = {
    url = "github:iknow/nix-utils";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, nix-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        packages.default = pkgs.hello;
      }
    ) // (
      let
        system = "x86_64-linux";

        inherit (nix-utils.utils.${system}) oci;

        pkgs = nixpkgs.legacyPackages.${system};
        selfPackages = self.packages.${system};
      in
      {
        dockerImages.hello.production = oci.makeSimpleImage {
          name = "hello";
          config = {
            Entrypoint = ["${selfPackages.default}/bin/hello"];
          };
        };

        testConfigurations = {};
      }
    );
}
