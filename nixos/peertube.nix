# Ensure that you've opened port 32400 on the router
# or you won't be able to reach it externally
{ lib, ... }:
let
  name = "peertube";
  port = 8970;
  user = "crow";
  address = "127.0.0.1";
  domain = "irlqt.net";
  subDomain = "vods";
in
{

  services = {
    "${name}" = {
      enable = true;
      group = "media-players";
      localDomain = "https://${subDomain}.${domain}";
      listenHttp = port;
      dataDirs = [
        "/zpools/ssd/apps/peertube"
      ];
      redis = {
        createLocally = true;
      };
      database = {
        createLocally = true;
      };
    };

    nginx = {
      # Setup the reverse proxy
      virtualHosts."${subDomain}.${domain}" = {
        http2 = true;
        forceSSL = true;
        acmeRoot = null;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://${address}:${(builtins.toString port)}";
          proxyWebsockets = true;
          # Only allow people connected via Wireguard to connect
          extraConfig = ''
          '';
        };
      };
    };
  };
}
