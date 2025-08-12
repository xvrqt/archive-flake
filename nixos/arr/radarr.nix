# Ensure that you've opened port 32400 on the router
# or you won't be able to reach it externally
{ domain, dataPath, ... }:
let
  name = "radarr";
  port = 7878;
  user = "crow";
  address = "127.0.0.1";
  subDomain = name;
in
{

  services = {
    "${name}" = {
      enable = true;
      user = user;
      # This group has access to '/zpools/hdd/media' and '/zpools/hdd/downloads'
      group = "pirates";

      dataDir = "${dataPath}/${name}";
      openFirewall = true;
    };

    nginx = {
      # Setup the reverse proxy
      virtualHosts."${subDomain}.${domain}" = {
        # listen = [{
        #   addr = "0.0.0.0/128";
        #   port = 8443;
        # }];
        # listenAddresses = [ "[2002:881b:3142:0:add9:173c:1dc0:a0fa]" ];
        # listenAddresses = [ "10.128.0.1" "100.64.0.0/10" ];
        http2 = true;
        forceSSL = true;
        acmeRoot = null;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://${address}:${(builtins.toString port)}";
          proxyWebsockets = true;
          # Only allow people connected via Wireguard to connect
          # extraConfig = ''
          #   proxy_ssl_server_name on;
          #   # allow 10.128.0.0/9;
          #   # deny all;
          # '';
        };
      };
    };
  };
}
