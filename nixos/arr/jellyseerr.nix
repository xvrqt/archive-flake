{ domain, ... }:
let
  name = "jellyseerr";
  port = 5055;
  address = "127.0.0.1";
  subDomain = name;
in
{
  services = {

    jellyseerr = {
      enable = false;
      inherit port;
      openFirewall = true;
    };

    nginx = {
      virtualHosts."${subDomain}.${domain}" = {
        forceSSL = true;
        acmeRoot = null;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://${address}:${(builtins.toString port)}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
