{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.opensearch;

  esConfig = ''
    network.host: ${cfg.listenAddress}
    cluster.name: ${cfg.cluster_name}

    http.port: ${toString cfg.port}
    transport.tcp.port: ${toString cfg.tcp_port}

    ${cfg.extraConf}
  '';

  configDir = cfg.dataDir + "/config";

  opensearchYml = pkgs.writeTextFile {
    name = "opensearch.yml";
    text = esConfig;
  };

  loggingConfigFilename = "log4j2.properties";
  loggingConfigFile = pkgs.writeTextFile {
    name = loggingConfigFilename;
    text = cfg.logging;
  };

  esPlugins = pkgs.buildEnv {
    name = "opensearch-plugins";
    paths = cfg.plugins;
    postBuild = "${pkgs.coreutils}/bin/mkdir -p $out/plugins";
  };

in {

  ###### interface

  options.services.opensearch = {
    enable = mkOption {
      description = "Whether to enable opensearch.";
      default = false;
      type = types.bool;
    };

    package = mkOption {
      description = "Opensearch package to use.";
      default = pkgs.opensearch;
      defaultText = "pkgs.opensearch";
      type = types.package;
    };

    listenAddress = mkOption {
      description = "Opensearch listen address.";
      default = "127.0.0.1";
      type = types.str;
    };

    port = mkOption {
      description = "Opensearch port to listen for HTTP traffic.";
      default = 9200;
      type = types.int;
    };

    tcp_port = mkOption {
      description = "Opensearch port for the node to node communication.";
      default = 9300;
      type = types.int;
    };

    cluster_name = mkOption {
      description = "Opensearch name that identifies your cluster for auto-discovery.";
      default = "opensearch";
      type = types.str;
    };

    extraConf = mkOption {
      description = "Extra configuration for opensearch.";
      default = "";
      type = types.str;
      example = ''
        node.name: "opensearch"
        node.master: true
        node.data: false
      '';
    };

    logging = mkOption {
      description = "Opensearch logging configuration.";
      default = ''
        logger.action.name = org.opensearch.action
        logger.action.level = info

        appender.console.type = Console
        appender.console.name = console
        appender.console.layout.type = PatternLayout
        appender.console.layout.pattern = [%d{ISO8601}][%-5p][%-25c{1.}] %marker%m%n

        rootLogger.level = info
        rootLogger.appenderRef.console.ref = console
      '';
      type = types.str;
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/opensearch";
      description = ''
        Data directory for opensearch.
      '';
    };

    extraCmdLineOptions = mkOption {
      description = "Extra command line options for the opensearch launcher.";
      default = [];
      type = types.listOf types.str;
    };

    extraJavaOptions = mkOption {
      description = "Extra command line options for Java.";
      default = [];
      type = types.listOf types.str;
      example = [ "-Djava.net.preferIPv4Stack=true" ];
    };

    plugins = mkOption {
      description = "Extra opensearch plugins";
      default = [];
      type = types.listOf types.package;
    };

  };

  ###### implementation

  config = mkIf cfg.enable {
    launchd.user.agents.opensearch = {
      path = with pkgs; [ coreutils inetutils gnugrep ];

      serviceConfig = {
        EnvironmentVariables = {
            OPENSEARCH_HOME = cfg.dataDir;
            OPENSEARCH_JAVA_OPTS = toString cfg.extraJavaOptions;
            OPENSEARCH_PATH_CONF = configDir;
        };

        SoftResourceLimits.NumberOfFiles = 1024000;
        HardResourceLimits.NumberOfFiles = 1024000;

        KeepAlive = true;
        RunAtLoad = true;
      };

      script = ''
        set -ex

        mkdir -m 0700 -p ${cfg.dataDir}

        # Install plugins
        ln -sfT ${esPlugins}/plugins ${cfg.dataDir}/plugins
        ln -sfT ${cfg.package}/lib ${cfg.dataDir}/lib
        ln -sfT ${cfg.package}/modules ${cfg.dataDir}/modules

        # opensearch needs to create the opensearch.keystore in the config directory
        # so this directory needs to be writable.
        mkdir -m 0700 -p ${configDir}

        # Note that we copy config files from the nix store instead of symbolically linking them
        # because otherwise X-Pack Security will raise the following exception:
        # java.security.AccessControlException:
        # access denied ("java.io.FilePermission" "/var/lib/opensearch/config/opensearch.yml" "read")

        cp -f ${opensearchYml} ${configDir}/opensearch.yml
        # Make sure the logging configuration for old opensearch versions is removed:
        rm -f "${configDir}/logging.yml"
        cp -f ${loggingConfigFile} ${configDir}/${loggingConfigFilename}
        mkdir -p ${configDir}/scripts
        cp -f ${cfg.package}/config/jvm.options ${configDir}/jvm.options

        if [ "$(id -u)" = 0 ]; then chown -R opensearch:opensearch ${cfg.dataDir}; fi

        exec ${cfg.package}/bin/opensearch ${toString cfg.extraCmdLineOptions}
      '';
    };

    environment.systemPackages = [ cfg.package ];
  };
}
