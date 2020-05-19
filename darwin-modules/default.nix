{ config, lib, pkgs, ... }:
{
  nixpkgs.overlays = [ (import ../overlays) ];

  imports = [
    ./elasticsearch.nix
    ./kibana.nix
    ./lorri.nix
    ./memcached.nix
    ./mysql.nix
  ];
}
