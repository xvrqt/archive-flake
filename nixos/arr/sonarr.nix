# Ensure that you've opened port 32400 on the router
# or you won't be able to reach it externally
{ domain, dataPath, ... }:
let
  name = "sonarr";
  port = 8989;
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
        listenAddresses = [ "10.128.0.1" ];
        http2 = true;
        forceSSL = true;
        acmeRoot = null;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://${address}:${(builtins.toString port)}";
          proxyWebsockets = true;
          # Only allow people connected via Wireguard to connect
          extraConfig = ''
            allow 10.128.0.0/16;
            deny all;
          '';
        };
      };
    };
  };
}
