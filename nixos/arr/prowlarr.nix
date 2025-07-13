# Ensure that you've opened port 32400 on the router
# or you won't be able to reach it externally
{ domain, ... }:
let
  name = "prowlarr";
  port = 9696;
  address = "127.0.0.1";
  subDomain = name;
in
{

  services = {
    "${name}" = {
      enable = true;
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
