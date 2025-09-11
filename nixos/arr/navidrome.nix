# Ensure that you've opened port 32400 on the router
# or you won't be able to reach it externally
{ domain, dataPath, allow-list, interfaces, ... }:
let
  name = "navidrome";
  user = name;

  port = 9898;
  address = "127.0.0.1";
  subDomain = name;
in
{

  users = {
    # Not a real user
    users."${name}".isSystemUser = true;
    # Allow access to the /zpools/hdd/media
    groups."media-players".members = [ "${name}" ];
  };

  services = {
    "${name}" = {
      enable = true;
      # Create a separate user for navidrome for security reasons
      user = user;
      # This group has access to '/zpools/hdd/media' and '/zpools/hdd/downloads'
      group = "pirates";

      openFirewall = true;

      settings = {
        Port = port;
        Address = address;
        MusicFolder = "/zpools/hdd/media/music";
        DataFolder = "${dataPath}/${name}";
        CacheFolder = "${dataPath}/${name}/cache";
        BaseUrl = "https://${subDomain}.${domain}";

        LastFM = {
          Enabled = true;
        };
      };
    };

    nginx = {
      # Setup the reverse proxy
      virtualHosts."${subDomain}.${domain}" = {
        # Only listen on private interfaces
        listenAddresses = interfaces;

        http2 = true;
        forceSSL = true;
        acmeRoot = null;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://${address}:${(builtins.toString port)}";
          proxyWebsockets = true;
          recommendedProxySettings = true;

          extraConfig = ''
            proxy_ssl_server_name on;
            ${allow-list}
            deny all;
          '';
        };
      };
    };
  };
}
