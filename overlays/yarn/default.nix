{ callPackage, fetchFromGitHub, fetchurl }:

let
  berry2nix-src = fetchFromGitHub {
    owner = "iknow";
    repo = "berry2nix";
    rev = "51e03af8431c1e773d2a23fb491fb6169c8786b8";
    sha256 = "sha256-rrtbGO+8mmaTWpt+E8rjSmvgIFW1ohM8gQUkcgJTQL0=";
  };

  inherit (callPackage (berry2nix-src + "/yarn") {}) yarn-patched;

  yarn-plugin-outdated = fetchurl {
    url = "https://raw.githubusercontent.com/mskelton/yarn-plugin-outdated/v4.0.2/bundles/@yarnpkg/plugin-outdated.js";
    sha256 = "sha256-PhGIXf0ylYLZ4kMNhqGHhk85hH5iA+JjEv14tHSgDK4=";
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
