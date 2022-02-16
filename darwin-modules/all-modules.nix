{ config, lib, pkgs, ... }:
{
  imports = [
    ./elasticsearch.nix
    ./kibana.nix
    ./memcached.nix
    ./mysql.nix
  ];
}
