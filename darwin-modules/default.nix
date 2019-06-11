{ config, lib, pkgs, ... }:
{
  nixpkgs.overlays = [ (import ../overlays/packages.nix) ];

  imports = [
    ./elasticsearch.nix
    ./kibana.nix
    ./lorri.nix
    ./memcached.nix
    ./mysql.nix
  ];
}
