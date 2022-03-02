{ config, lib, pkgs, ... }:
{
  imports = [
    ./opensearch-dashboards.nix
    ./opensearch.nix
  ];
}
