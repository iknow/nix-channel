{ runCommand, lib, makeWrapper, jq, curl }:

runCommand "branch-server-ssh" {
  nativeBuildInputs = [ makeWrapper ];
} ''
  mkdir -p $out/bin
  install -m 755 ${./bssh} $out/bin/bssh
  wrapProgram $out/bin/bssh \
    --prefix PATH : ${lib.makeBinPath [ jq curl ]}
''
