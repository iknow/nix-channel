{ luajit, libuv, fetchgit,
 cmake, pkgconfig, darwin,
 neovim-unwrapped, wrapNeovim
}:

let
  lua = luajit;

  libuv1_30 = libuv.overrideAttrs (old: {
    name = "libuv-1.30.1";
    src = fetchgit {
      url = "https://github.com/libuv/libuv";
      rev = "v1.30.1";
      sha256 = "16l207g9qwckxn0vnbnwiybhw6083imdwyfd6ipfsl44b1m8jmf7";
    };
  });

  lua-compat-53 = fetchgit {
    url = "https://github.com/keplerproject/lua-compat-5.3";
    rev = "v0.7";
    sha256 = "02a14nvn7aggg1yikj9h3dcf8aqjbxlws1bfvqbpfxv9d5phnrpz";
  };

  libluv = lua.stdenv.mkDerivation {
    name = "luv";
    version = "0.30.0-0";

    src = fetchgit {
      url = "https://github.com/luvit/luv";
      rev = "1.30.0-0";
      fetchSubmodules = false;
      sha256 = "0igbl36qz31xd3ckxlf6i8s91qwnp68h607pcpvmlg895dq43zl6";
    };

    nativeBuildInputs = [cmake pkgconfig];
    buildInputs = [lua libuv1_30 darwin.apple_sdk.frameworks.ApplicationServices];

    cmakeFlags = [
      "-DBUILD_MODULE=OFF"
      "-DBUILD_SHARED_LIBS=OFF"
      "-DWITH_SHARED_LIBUV=ON"
      "-DLUA_BUILD_TYPE=System"
      "-DLUA_COMPAT53_DIR=${lua-compat-53}"
    ];
  };

  neovim-unwrapped-nightly = (neovim-unwrapped.overrideAttrs(old: rec {
    name = "neovim-unwrapped-${version}";
    version = "0.4.0";

    src = fetchgit {
      url = "https://github.com/neovim/neovim";
      rev = "42bdccdf6c36576a080becc8b68993af7c855aa6";
      sha256 = "04cv15jbr9kdcrmlykkwra03v1fam30hrhd8fpa8zp9isxaipm8d";
    };

    buildInputs = old.buildInputs ++ [libluv];
  })).override {
    inherit lua;
    libuv = libuv1_30;
  };

in wrapNeovim neovim-unwrapped-nightly {}
