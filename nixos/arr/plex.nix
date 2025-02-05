# Ensure that you've opened port 32400 on the router
# or you won't be able to reach it externally
{ domain, dataPath, ... }:
let
  name = "plex";
  port = 32400;
  user = name;
  address = "127.0.0.1";
  subDomain = name;
in
{

  services = {
    # Enable Plex
    plex = {
      enable = true;
      user = user;
      # This group has access to '/zpools/hdd/media' 
      group = "media-players";

      dataDir = "${dataPath}/${name}";
      openFirewall = true;
    };

    nginx = {
      # Setup the reverse proxy
      # Plex uses 'xvrqt.com' because it's an external facing service
      virtualHosts."plex.xvrqt.com" = {
        http2 = true;
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
