{ lib, bundlerApp, ruby, defaultGemConfig, makeWrapper, fetchpatch }:

bundlerApp rec {
  pname = "phraseapp_updater";
  exes = ["phraseapp_updater"];

  inherit ruby;

  gemdir = ./.;

  buildInputs = [makeWrapper];

  postBuild = ''
    wrapProgram $out/bin/phraseapp_updater --prefix PATH : ${lib.makeBinPath [ ruby ]}
  '';

  gemConfig = defaultGemConfig // {
    # HashDiff presently has an intrusive unconditional deprecation message.
    # We use it correctly, we don't need to see the message.
    hashdiff = attrs: {
      patches = [
        (fetchpatch {
          url = "https://github.com/liufengyun/hashdiff/commit/2dc6adc71739c4aec23c1a946e25ea36f8c69f58.diff";
          sha256="1pibvad2fxpg30pjdhk2q8ly4pfn7yiyv331zdvw9viqickx225j"; })
      ];
      dontBuild = false;
    };
  };

  meta = with lib; {
    description = "A tool for merging data on PhraseApp with local changes (usually two git revisions)";
    homepage = https://github.com/iknow/phraseapp_updater;
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
