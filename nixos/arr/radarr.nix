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
    # Enable Plex
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
        http2 = true;
        forceSSL = true;
        acmeRoot = null;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://${address}:${(builtins.toString port)}";
          proxyWebsockets = true;
          # Only allow people connected via Wireguard to connect
          extraConfig = ''
            allow 2.2.2.0/24;
            deny all;
          '';
        };
      };
    };
  };
}
