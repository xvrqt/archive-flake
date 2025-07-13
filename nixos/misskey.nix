#Misskey
{ pkgs
, inputs
, config
, ...
}: {
  services = {
    misskey = {
      enable = true;
      meilisearch.createLocally = true;
      database.createLocally = true;
      redis.createLocally = true;
      reverseProxy = {
        enable = true;
        host = "irlqt.me";
        ssl = true;
        webserver.nginx = {
          listenAddresses = [ "10.128.0.1" "192.168.1.6" ];
          forceSSL = true;
          enableACME = true;
          acmeRoot = null;
          serverName = "irlqt.me";
          # locations."/" = {
          #          proxyPass = "http://127.0.0.1:3000";
          #          proxyWebsockets = true;
          # };
        };
      };
      settings = { };
    };
  };
}
