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
        # This is actually prolly wrong since it's available externally ?
        # listenAddresses = [ "10.128.0.1" ];
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
