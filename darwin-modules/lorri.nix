{ config, lib, pkgs, ... }:

with lib;

let
  lorri = pkgs.lorri;
  cfg   = config.services.lorri;

  mkService = path: (
    let
      name = (baseNameOf path);
    in
    {
      "lorri-${name}" = {
        serviceConfig = {
          WorkingDirectory = path;
          EnvironmentVariables = { };
          KeepAlive = true;
          RunAtLoad = true;
        };
        script = ''
          source ${config.system.build.setEnvironment}
          exec ${lorri}/bin/lorri watch
        '';
      };
    });
in
{
  options = {
    services.lorri = {
      paths = mkOption {
        description = "Paths to watch.";
        default = [];
        type = types.listOf types.str;
      };
    };
  };

  config = mkIf (cfg.paths != []) {
    environment.systemPackages = [ lorri ];
    launchd.user.agents = mkMerge (map mkService cfg.paths);
  };
}
