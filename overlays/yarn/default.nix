{ callPackage, fetchFromGitHub, fetchurl }:

let
  berry2nix-src = fetchFromGitHub {
    owner = "iknow";
    repo = "berry2nix";
    rev = "83d3057e65cfdca1bb67ff14df983279e2dfbdaf";
    sha256 = "sha256-DsuCKJbPEQLpPJgS1AfDZe46GwAS2NFhHNhPBQjU4Os=";
  };

  inherit (callPackage (berry2nix-src + "/yarn") {}) yarn-patched;

  yarn-plugin-outdated = fetchurl {
    url = "https://raw.githubusercontent.com/mskelton/yarn-plugin-outdated/v4.0.1/bundles/@yarnpkg/plugin-outdated.js";
    sha256 = "sha256-6cARNfm2Gyr3GrL4zpYnEa2GTm96t7tO3PjAAIOnvEo=";
  };

  yarn-plugin-iknow = fetchurl {
    url = "https://raw.githubusercontent.com/iknow/yarn-plugin-iknow/5c1259558540ac48ccfcbf2bd7a7a30bd442eee3/bundles/@yarnpkg/plugin-iknow.js";
    sha256 = "sha256-sxLsPZE444Wl2HPcvSOobZioYH6Vo8aj/rwUyC8mW6Y=";
  };
in
{
  berry2nix = callPackage (berry2nix-src + "/lib.nix") {};

  yarn-iknow = yarn-patched.override {
    yarn-js = yarn-patched.yarn-js.override {
      patches = [
        ./direct-dedupe.patch
      ];
    };
    plugins = [
      yarn-plugin-outdated
      yarn-plugin-iknow
    ];
  };
}
