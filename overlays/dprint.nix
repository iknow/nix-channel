{ dprint
, jq
, fetchurl
, runCommand
, makeWrapper

, dprintJson
}:

let
  dprintConfig = builtins.fromJSON (builtins.readFile dprintJson);

  hashes = {
    "https://plugins.dprint.dev/typescript-0.85.0.wasm" = "sha256-FMMoXkWL7oTZYCbh108dJtziUKgvvGH6FwK/cglUGLo=";
    "https://plugins.dprint.dev/typescript-0.88.1.wasm" = "sha256-6ihMZIWi9GyNy1ePipVv+LUn0h/khSNuNzPzqhEL7/8=";
  };

  prefetchPlugin = url: fetchurl {
    inherit url;
    sha256 = hashes."${url}" or (throw "No known hash for dprint plugin '${url}', please update release.nix");
  };

  plugins = map prefetchPlugin dprintConfig.plugins;

  # used to map nix paths back to their remote urls in the plugin cache
  # manifest so that the original dprint.json can be used
  urls = builtins.listToAttrs (map (p: {
    name = "local:${builtins.unsafeDiscardStringContext p}";
    value = "remote:${p.url}";
  }) plugins);

  dprintCache = runCommand "dprint-cache" {
    nativeBuildInputs = [ dprint jq ];

    mapping = builtins.toJSON urls;

    simplifiedConfig = builtins.toJSON {
      inherit plugins;
    };

    passAsFile = [ "simplifiedConfig" ];
  } ''
    mkdir -p "$out"
    export DPRINT_CACHE_DIR="$out"

    # run dprint so it caches the plugins
    dprint output-file-paths -c "$simplifiedConfigPath"

    # cleanup lock files
    rm -r "$out/locks"

    # map keys with nix paths back to the original urls
    # also fixes createdTime to epoch
    jq --argjson mapping "$mapping" '
      if .schemaVersion != 8 then error("dprint cache schema version changed") end |
      .plugins |= with_entries(.key = $mapping[.key] | .value.createdTime = 1)
    ' "$out/plugin-cache-manifest.json" > tmp.json
    mv tmp.json "$out/plugin-cache-manifest.json"
  '';
in
runCommand "dprint-wrapped" {
  nativeBuildInputs = [ makeWrapper ];
} ''
  mkdir -p "$out/bin"
  makeWrapper "${dprint}/bin/dprint" "$out/bin/dprint" \
    --set DPRINT_CACHE_DIR "${dprintCache}"
''
