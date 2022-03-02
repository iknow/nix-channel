{ config, lib, pkgs, ... }:
{
  imports = [
    ./elasticsearch.nix
    ./kibana.nix
    ./opensearch-dashboards.nix
    ./opensearch.nix
    ./memcached.nix
    ./mysql.nix
  ];
}
