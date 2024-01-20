{ lib, bundlerApp, ruby, makeWrapper }:

bundlerApp rec {
  pname = "phraseapp_updater";
  exes = ["phraseapp_updater"];

  inherit ruby;

  gemdir = ./.;

  buildInputs = [makeWrapper];

  postBuild = ''
    wrapProgram $out/bin/phraseapp_updater --prefix PATH : ${lib.makeBinPath [ ruby ]}
  '';

  meta = with lib; {
    description = "A tool for merging data on PhraseApp with local changes (usually two git revisions)";
    homepage = "https://github.com/iknow/phraseapp_updater";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
