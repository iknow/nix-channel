{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.mysql;

  mysql = cfg.package;

  isMariaDB =
    let
      pName = _p: (builtins.parseDrvName (_p.name)).name;
    in pName mysql == pName pkgs.mariadb;
  isMysqlAtLeast57 =
    let
      pName = _p: (builtins.parseDrvName (_p.name)).name;
    in (pName mysql == pName pkgs.mysql57)
       && ((builtins.compareVersions mysql.version "5.7") >= 0);

  mysqldOptions =
    "--datadir=${cfg.dataDir} --basedir=${mysql}";
  # For MySQL 5.7+, --insecure creates the root user without password
  # (earlier versions and MariaDB do this by default).
  installOptions =
    "${mysqldOptions} ${lib.optionalString isMysqlAtLeast57 "--insecure"}";

in

{

  ###### interface

  options = {

    services.mysql = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = "
          Whether to enable the MySQL server.
        ";
      };

      package = mkOption {
        type = types.package;
        example = literalExample "pkgs.mysql";
        description = "
          Which MySQL derivation to use. MariaDB packages are supported too.
        ";
      };

      bind = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = literalExample "0.0.0.0";
        description = "Address to bind to. The default is to bind to all addresses";
      };

      port = mkOption {
        type = types.int;
        default = 3306;
        description = "Port of MySQL";
      };

      dataDir = mkOption {
        type = types.path;
        example = "/var/lib/mysql";
        description = "Location where MySQL stores its table files";
      };

      extraOptions = mkOption {
        type = types.lines;
        default = "";
        example = ''
          key_buffer_size = 6G
          table_cache = 1600
          log-error = /var/log/mysql_err.log
        '';
        description = ''
          Provide extra options to the MySQL configuration file.

          Please note, that these options are added to the
          <literal>[mysqld]</literal> section so you don't need to explicitly
          state it again.
        '';
      };
    };
  };


  ###### implementation

  config = mkIf config.services.mysql.enable {

    environment.systemPackages = [mysql];

    environment.etc."my.cnf".text =
    ''
      [mysqld]
      port = ${toString cfg.port}
      datadir = ${cfg.dataDir}
      ${optionalString (cfg.bind != null) "bind-address = ${cfg.bind}" }
      ${cfg.extraOptions}
    '';

    # nix-darwin idiom is to run services as the user.
    system.activationScripts.preActivation.text = ''
      mkdir -m 0755 -p /var/run/mysqld
      chown $SUDO_USER /var/run/mysqld
    '';

    launchd.user.agents.mysql = {
      serviceConfig = {
        KeepAlive = true;
        RunAtLoad = true;
      };

      script = ''
        set -ex
        PATH="${makeBinPath [pkgs.nettools]}:$PATH"

        mkdir -m 0700 -p ${cfg.dataDir}

        if ! test -e ${cfg.dataDir}/mysql; then
          ${mysql}/bin/mysql_install_db --defaults-file=/etc/my.cnf ${installOptions}
          touch /tmp/mysql_init
        fi

        exec ${mysql}/bin/mysqld --defaults-file=/etc/my.cnf ${mysqldOptions} $_WSREP_NEW_CLUSTER $_WSREP_START_POSITION
      '';
    };
  };
}
