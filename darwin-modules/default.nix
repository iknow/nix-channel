{ config, lib, pkgs, ... }:
{
  imports = [
    ./elasticsearch.nix
    ./kibana.nix
    ./lorri.nix
    ./memcached.nix
  ];
}
