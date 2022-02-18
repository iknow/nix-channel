{ config, lib, pkgs, ... }:
{
  nixpkgs.overlays = [ (import ../overlays) ];

  imports = [
    ./all-modules.nix
  ];
}
