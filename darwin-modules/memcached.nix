{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.memcached;

  memcached = pkgs.memcached;

in

{

  ###### interface

  options = {

    services.memcached = {

      enable = mkOption {
        default = false;
        description = "
          Whether to enable Memcached.
        ";
      };

      listen = mkOption {
        default = "127.0.0.1";
        description = "The IP address to bind to";
      };

      port = mkOption {
        default = 11211;
        description = "The port to bind to";
      };

      maxMemory = mkOption {
        default = 64;
        description = "The maximum amount of memory to use for storage, in megabytes.";
      };

      maxConnections = mkOption {
        default = 1024;
        description = "The maximum number of simultaneous connections";
      };

      extraOptions = mkOption {
        default = [];
        description = "A list of extra options that will be added as a suffix when running memcached";
      };
    };

  };

  ###### implementation

  config = mkIf config.services.memcached.enable {

    environment.systemPackages = [ memcached ];

    launchd.user.agents.memcached = {
      serviceConfig = {
        EnvironmentVariables = { };
        KeepAlive = true;
        RunAtLoad = true;
      };

      script = ''
        exec ${memcached}/bin/memcached \
         -l ${cfg.listen}\
         -p ${toString cfg.port}\
         -m ${toString cfg.maxMemory}\
         -c ${toString cfg.maxConnections}\
          ${concatStringsSep " " cfg.extraOptions}
      '';
    };
  };
}
