{ callPackage, fetchFromGitHub, fetchurl }:

let
  berry2nix-src = fetchFromGitHub {
    owner = "iknow";
    repo = "berry2nix";
    rev = "51129dab790cb832e8ab9dd34b6cd5a52d80514d";
    sha256 = "sha256-amYnoqtmChi2O4GJv6Fqx+XIh8xIEpMbGy5sEMAmrcQ=";
  };

  inherit (callPackage (berry2nix-src + "/yarn") {}) yarn-patched;

  yarn-plugin-workspace-tools = fetchurl {
    url = "https://repo.yarnpkg.com/${yarn-patched.version}/packages/plugin-workspace-tools/bin/@yarnpkg/plugin-workspace-tools.js";
    sha256 = "sha256-hgBbcQ3fvrQP8bqAGsMLYcYM/WhyrBMQMUNVJY3dCxE=";
  };

  yarn-plugin-interactive-tools = fetchurl {
    url = "https://repo.yarnpkg.com/${yarn-patched.version}/packages/plugin-interactive-tools/bin/@yarnpkg/plugin-interactive-tools.js";
    sha256 = "sha256-coBeeoPdV3Y/FwerT6bb1TkaYPgnH8M/tVps0qVbEUM=";
  };

  yarn-plugin-version = fetchurl {
    url = "https://repo.yarnpkg.com/${yarn-patched.version}/packages/plugin-version/bin/@yarnpkg/plugin-version.js";
    sha256 = "sha256-JXucgc21umG5L1ok6nu5i5g6uKPlAKRfl318Dav57t4=";
  };

  yarn-plugin-outdated = fetchurl {
    url = "https://raw.githubusercontent.com/mskelton/yarn-plugin-outdated/v3.2.4/bundles/@yarnpkg/plugin-outdated.js";
    sha256 = "sha256-lB3TaXrcmPKr8sUfHjVMMP6WQoGyQFeNy5HXlUIOWfY=";
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
      yarn-plugin-workspace-tools
      yarn-plugin-interactive-tools
      yarn-plugin-version
      yarn-plugin-outdated
      yarn-plugin-iknow
    ];
  };
}
