{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "kustomize";
  version = "3.8.7";
  # rev is the commit hash for this version, mainly for kustomize version
  # command output
  rev = "ad092cc7a91c07fdf63a2e4b7f13fa588a39af4f";

  # static build
  CGO_ENABLED = 0;

  buildFlagsArray = let t = "sigs.k8s.io/kustomize/api/provenance"; in
    ''
      -ldflags=
        -s -X ${t}.version=${version}-patched
           -X ${t}.gitCommit=${rev}
    '';

  src = fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = pname;
    rev = "kustomize/v${version}";
    sha256 = "1942cyaj6knf8mc3q2vcz6rqqc6lxdd6nikry9m0idk5l1b09x1m";
  };

  # TODO remove patches once
  # https://github.com/kubernetes-sigs/kustomize/pull/3244 is merged
  # and in a proper release
  patches = [
    # this patch is needed otherwise other patches won't take effect
    ./unpin-versions.patch
    ./go-getter-http-only.patch
    ./single-fetch.patch
  ];

  modRoot = "kustomize";

  vendorSha256 = "1mz9bx2fjm3mlybily2pzgir746by69qxg1gpwsdi45i99hcbaj4";
}
