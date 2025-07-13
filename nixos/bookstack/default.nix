{ lib
, config
, ...
}:
let
  userInfo = (builtins.getFlake "github:xvrqt/identities-flake").userInfo;

  name = "bookstack";
  port = 11223;
  address = "127.0.0.1";
  domain = "irlqt.net";
  subDomain = "docs";

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
      user = name;
      group = name;
      hostname = "${subDomain}.${domain}";
      settings = {
        APP_URL = "https://${subDomain}.${domain}";
        APP_KEY_FILE = config.age.secrets.bookstack_key.path;
      };
      dataDir = "/zpools/ssd/apps/bookstack";
      nginx = {
        http2 = true;
        forceSSL = true;
        acmeRoot = null;
        enableACME = true;
        listen = [
          {
            addr = "${address}";
            port = port;
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
    #       proxyPass = "http://${address}:${(builtins.toString port)}";
    #       proxyWebsockets = true;
    #       # Only allow people connected via Wireguard to connect
    #       extraConfig = ''
    #         client_max_body_size 512M;
    #       '';
    #     };
    #   };
    # };
  };
}
