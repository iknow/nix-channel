{ nixpkgs ? import <nixpkgs> {} }:
{
  darwin-modules = import ./darwin-modules/module-list.nix;
}
