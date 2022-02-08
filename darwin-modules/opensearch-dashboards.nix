{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.opensearch-dashboards;

  ge7 = true;
  lt6_6 = false;

  cfgFile = pkgs.writeText "opensearch-dashboards.json" (builtins.toJSON (
    (filterAttrsRecursive (n: v: v != null) ({
      server.host = cfg.listenAddress;
      server.port = cfg.port;
      server.ssl.certificate = cfg.cert;
      server.ssl.key = cfg.key;

      opensearchDashboards.index = cfg.index;
      opensearchDashboards.defaultAppId = cfg.defaultAppId;

      opensearch.hosts = cfg.opensearch.hosts;
      opensearch.username = cfg.opensearch.username;
      opensearch.password = cfg.opensearch.password;

      opensearch.ssl.certificate = cfg.opensearch.cert;
      opensearch.ssl.key = cfg.opensearch.key;
      opensearch.ssl.certificateAuthorities = cfg.opensearch.certificateAuthorities;
    } // cfg.extraConf)
  )));

in {
  options.services.opensearch-dashboards = {
    enable = mkEnableOption "enable opensearch-dashboards service";

    listenAddress = mkOption {
      description = "Opensearch-Dashboards listening host";
      default = "127.0.0.1";
      type = types.str;
    };

    port = mkOption {
      description = "Opensearch-Dashboards listening port";
      default = 5601;
      type = types.int;
    };

    cert = mkOption {
      description = "Opensearch-Dashboards ssl certificate.";
      default = null;
      type = types.nullOr types.path;
    };

    key = mkOption {
      description = "Opensearch-Dashboards ssl key.";
      default = null;
      type = types.nullOr types.path;
    };

    index = mkOption {
      description = "Opensearch index to use for saving opensearch-dashboards config.";
      default = ".opensearch_dashboards";
      type = types.str;
    };

    defaultAppId = mkOption {
      description = "Opensearch default application id.";
      default = "discover";
      type = types.str;
    };

    opensearch = {
      hosts = mkOption {
        description = ''
          The URLs of the Opensearch instances to use for all your queries.
          All nodes listed here must be on the same cluster.

          Defaults to <literal>[ "http://localhost:9200" ]</literal>.
        '';
        default = null;
        type = types.nullOr (types.listOf types.str);
      };

      username = mkOption {
        description = "Username for opensearch basic auth.";
        default = null;
        type = types.nullOr types.str;
      };

      password = mkOption {
        description = "Password for opensearch basic auth.";
        default = null;
        type = types.nullOr types.str;
      };

      certificateAuthorities = mkOption {
        description = ''
          CA files to auth against opensearch.
        '';
        default = [];
        type = types.listOf types.path;
      };

      cert = mkOption {
        description = "Certificate file to auth against opensearch.";
        default = null;
        type = types.nullOr types.path;
      };

      key = mkOption {
        description = "Key file to auth against opensearch.";
        default = null;
        type = types.nullOr types.path;
      };
    };

    package = mkOption {
      description = "Opensearch-Dashboards package to use";
      default = pkgs.opensearch-dashboards;
      defaultText = "pkgs.opensearch-dashboards";
      example = "pkgs.opensearch-dashboards5";
      type = types.package;
    };

    dataDir = mkOption {
      description = "Opensearch-Dashboards data directory";
      default = "/var/lib/opensearch-dashboards";
      type = types.path;
    };

    extraConf = mkOption {
      description = "Opensearch-Dashboards extra configuration";
      default = {};
      type = types.attrs;
    };
  };

  config = mkIf (cfg.enable) {
    assertions = [
    ];

    launchd.user.agents.opensearch-dashboards = {
      serviceConfig = {
        EnvironmentVariables = {
          BABEL_CACHE_PATH = "${cfg.dataDir}/.babelcache.json";
        };
        KeepAlive = true;
        RunAtLoad = true;
      };

      script = ''
        exec ${cfg.package}/bin/opensearch-dashboards --config ${cfgFile} --path.data ${cfg.dataDir}
      '';
    };

    environment.systemPackages = [ cfg.package ];
  };
}
