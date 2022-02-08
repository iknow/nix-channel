{ config, lib, options, pkgs, ... }:

with lib;

let
  cfg = config.services.opensearch-dashboards;
  opt = options.services.opensearch-dashboards;

  cfgFile = pkgs.writeText "opensearch-dashboards.json" (builtins.toJSON (
    (filterAttrsRecursive (n: v: v != null && v != []) ({
      server.host = cfg.listenAddress;
      server.port = cfg.port;
      server.ssl.certificate = cfg.cert;
      server.ssl.key = cfg.key;

      opensearchDashboards.index = cfg.index;
      opensearchDashboards.defaultAppId = cfg.defaultAppId;

      elasticsearch.hosts = cfg.elasticsearch.hosts;
      elasticsearch.username = cfg.elasticsearch.username;
      elasticsearch.password = cfg.elasticsearch.password;

      elasticsearch.ssl.certificate = cfg.elasticsearch.cert;
      elasticsearch.ssl.key = cfg.elasticsearch.key;
      elasticsearch.ssl.certificateAuthorities = cfg.elasticsearch.certificateAuthorities;
    } // cfg.extraConf)
  )));

in {
  options.services.opensearch-dashboards = {
    enable = mkEnableOption "opensearch-dashboards service";

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
      description = "Elasticsearch index to use for saving opensearch-dashboards config.";
      default = ".opensearch_dashboards";
      type = types.str;
    };

    defaultAppId = mkOption {
      description = "Elasticsearch default application id.";
      default = "discover";
      type = types.str;
    };

    elasticsearch = {
      hosts = mkOption {
        description = ''
          The URLs of the Elasticsearch instances to use for all your queries.
          All nodes listed here must be on the same cluster.

          Defaults to <literal>[ "http://localhost:9200" ]</literal>.
        '';
        default = null;
        type = types.nullOr (types.listOf types.str);
      };

      username = mkOption {
        description = "Username for elasticsearch basic auth.";
        default = null;
        type = types.nullOr types.str;
      };

      password = mkOption {
        description = "Password for elasticsearch basic auth.";
        default = null;
        type = types.nullOr types.str;
      };

      certificateAuthorities = mkOption {
        description = ''
          CA files to auth against elasticsearch.
        '';
        default = [];
        type = types.listOf types.path;
      };

      cert = mkOption {
        description = "Certificate file to auth against elasticsearch.";
        default = null;
        type = types.nullOr types.path;
      };

      key = mkOption {
        description = "Key file to auth against elasticsearch.";
        default = null;
        type = types.nullOr types.path;
      };
    };

    package = mkOption {
      description = "Opensearch-Dashboards package to use";
      default = pkgs.opensearch-dashboards;
      defaultText = literalExpression "pkgs.opensearch-dashboards";
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
    systemd.services.opensearch-dashboards = {
      description = "Opensearch-Dashboards Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "elasticsearch.service" ];
      environment = { BABEL_CACHE_PATH = "${cfg.dataDir}/.babelcache.json"; };
      serviceConfig = {
        ExecStart =
          "${cfg.package}/bin/opensearch-dashboards" +
          " --config ${cfgFile}" +
          " --path.data ${cfg.dataDir}";
        User = "opensearch-dashboards";
        WorkingDirectory = cfg.dataDir;
      };
    };

    environment.systemPackages = [ cfg.package ];

    users.users.opensearch-dashboards = {
      isSystemUser = true;
      description = "Opensearch-Dashboards service user";
      home = cfg.dataDir;
      createHome = true;
      group = "opensearch-dashboards";
    };
    users.groups.opensearch-dashboards = {};
  };
}
