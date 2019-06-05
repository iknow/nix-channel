{ nixpkgs ? import <nixpkgs> {} }:
{
  darwin-modules = import ./darwin-modules;
}
