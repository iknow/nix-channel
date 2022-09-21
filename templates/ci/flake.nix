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

        accounts = {
          users.deploy = {
            uid = 999;
            group = "deploy";
            home = "/home/deploy";
            shell = "/bin/sh";
          };
          groups.deploy.gid = 999;
        };

        baseLayer = {
          name = "base-layer";
          path = [ pkgs.busybox ];
          entries = oci.makeFilesystem {
            inherit accounts;
            hosts = true;
            tmp = true;
            usrBinEnv = "${pkgs.busybox}/bin/env";
            binSh = "${pkgs.busybox}/bin/sh";
          };
        };

        testImage = oci.makeSimpleImage {
          name = "base-test";
          config = {
            User = "deploy";
            WorkingDir = "/home/deploy";
          };
          layers = [ baseLayer ];
        };
      in
      {
        dockerImages.hello.production = oci.makeSimpleImage {
          name = "hello";
          config = {
            User = "deploy";
            WorkingDir = "/home/deploy";
            Entrypoint = ["${selfPackages.default}/bin/hello"];
          };
          layers = [ baseLayer ];
        };

        testConfigurations.hello = {
          useHostStore = true;
          image = testImage;
          command = [(pkgs.writeScript "test.sh" ''
            #!${pkgs.runtimeShell}

            set -e

            ${selfPackages.default}/bin/hello
          '')];
        };
      }
    );
}
