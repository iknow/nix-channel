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

  yarn-plugin-outdated = fetchurl {
    url = "https://raw.githubusercontent.com/mskelton/yarn-plugin-outdated/v3.2.4/bundles/@yarnpkg/plugin-outdated.js";
    sha256 = "sha256-lB3TaXrcmPKr8sUfHjVMMP6WQoGyQFeNy5HXlUIOWfY=";
  };

  yarn-plugin-iknow = fetchurl {
    url = "https://raw.githubusercontent.com/iknow/yarn-plugin-iknow/86d51659731c79452c6a1c5b54322f1a64758c2d/bundles/@yarnpkg/plugin-iknow.js";
    sha256 = "sha256-eZzk6utiBZZ2+RBfxHiGAzSkSZq9h0BEECHVDl/8LIM=";
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
      yarn-plugin-outdated
      yarn-plugin-iknow
    ];
  };
}
