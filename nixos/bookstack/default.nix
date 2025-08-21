{ pkgs
, inputs
, config
, machine
, ...
}:
let
  name = "bookstack";

  # Only available on the irlqt-net
  address = inputs.networking.config.machines.${machine}.ip.v4.tailnet;

  domain = "irlqt.net";
  subDomain = "wiki";
in

{
  services = {
    bookstack = {
      enable = true;

      user = name;
      group = "nginx";

      hostname = "${subDomain}.${domain}";
      dataDir = "/zpools/ssd/apps/bookstack";

      settings = {
        APP_URL = "https://${subDomain}.${domain}";
        APP_KEY_FILE = config.age.secrets.bookstack_key.path;

        # Configure Database
        DB_HOST = "localhost";
        DB_PORT = 3306;
        DB_USERNAME = "bookstack";
        DB_DATABASE = "bookstack";
        DB_SOCKET = "/run/mysqld/mysqld.sock";
      };


      # Reverse proxy
      # Goddamn I wish they just exposed a port like a normal daemon
      # Stop trying to do things for me
      nginx = {
        http2 = true;
        forceSSL = true;
        acmeRoot = null;
        enableACME = true;
        serverName = "${subDomain}.${domain}";
        listen = [
          {
            addr = address;
            port = 443;
            ssl = true;
          }
          {
            addr = "127.0.0.1";
            port = 80;
          }
        ];
      };
    };

    # Configure the database to be used by bookstack
    mysql = {
      enable = true;
      package = pkgs.mariadb;

      ensureDatabases = [ "bookstack" ];
      settings.mysqld.character-set-server = "utf8mb4";

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

  # Bookstack requries a secret to encrypt data
  # We make use of our secrets-flake to decrupt it to the /key
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
}
