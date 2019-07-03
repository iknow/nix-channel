{ config, lib, pkgs, ... }:

with lib;

let
  lorri = pkgs.lorri;
in
{
  options = {
    services.lorri = {
      enable = mkEnableOption "enable Lorri daemon";
    };
  };

  config = mkIf config.services.lorri.enable {
    environment.systemPackages = [ lorri ];
    launchd.user.agents = {
      "lorri-daemon" = {
        serviceConfig = {
          WorkingDirectory = (builtins.getEnv "HOME");
          EnvironmentVariables = { };
          KeepAlive = true;
          RunAtLoad = true;
        };
        script = ''
          source ${config.system.build.setEnvironment}
          exec ${lorri}/bin/lorri daemon
        '';
      };
    };
  };
}
