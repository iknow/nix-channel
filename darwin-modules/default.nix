{ config, lib, pkgs, ... }:
{
  nixpkgs.overlays = [ (import ../overlays) ];

  imports = [
    ./elasticsearch.nix
    ./kibana.nix
    ./memcached.nix
    ./mysql.nix
  ];
}
