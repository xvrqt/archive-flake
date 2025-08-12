{ pkgs
, config
, ...
}:
let
  userInfo = (builtins.getFlake "github:xvrqt/identities-flake").userInfo;

  name = "bookstack";
  port = 13132;
  address = "127.0.0.1";
  domain = "irlqt.net";
  subDomain = "wiki";

in

{
  age.secrets.bookstack_key = {
    # The secret source file to be decrypted
    file = ./secrets/appKeyFile.txt;
    # Folder to decrypt into
    name = "bookstack/appKeyFile.txt";

    # Newly created file permissions
    mode = "400";
    owner = "bookstack";
    symlink = true;
  };
  services = {
    bookstack = {
      enable = true;
      # user = name;
      # group = name;
      hostname = "${subDomain}.${domain}";
      settings = {
        APP_URL = "https://${subDomain}.${domain}";
        APP_KEY_FILE = config.age.secrets.bookstack_key.path;

        DB_HOST = "localhost";
        DB_PORT = 3306;
        DB_USERNAME = "bookstack";
        DB_DATABASE = "bookstack";
        DB_SOCKET = "/run/mysqld/mysqld.sock";
      };

      dataDir = "/zpools/hdd/wikis/bookstack";

      nginx = {
        # onlySSL = false;
        http2 = true;
        forceSSL = true;
        acmeRoot = null;
        enableACME = true;
        serverName = "wiki.irlqt.net";
        listen = [
          {
            addr = "0.0.0.0";
            port = 443;
            ssl = true;
          }
        ];
      };
    };
    # nginx = {
    #   # Setup the reverse proxy
    #   virtualHosts."${subDomain}.${domain}" = {
    #     http2 = true;
    #     forceSSL = true;
    #     acmeRoot = null;
    #     enableACME = true;
    #     locations."/" = {
    #       proxyPass = "http://127.0.0.1:${toString port}";
    #       proxyWebsockets = true;
    #       # Only allow people connected via Wireguard to connect
    #       extraConfig = ''
    #         client_max_body_size 512M;
    #       '';
    #     };
    #   };
    # };
    mysql = {
      enable = true;
      package = pkgs.mariadb;

      settings.mysqld.character-set-server = "utf8mb4";
      ensureDatabases = [ "bookstack" ];

      ensureUsers = [
        {
          name = "bookstack";
          ensurePermissions = {
            "bookstack.*" = "ALL PRIVILEGES";
          };
        }
      ];

    };
  };
}
