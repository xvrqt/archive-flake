# Ensure that you've opened port 32400 on the router
# or you won't be able to reach it externally
{ domain, dataPath, allow-list, interfaces, ... }:
let
  name = "radarr";
  user = name;

  port = 7878;
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
    radarr = {
      enable = true;
      # Create a separate user for radarr for security reasons
      user = user;
      # This group has access to '/zpools/hdd/media' and '/zpools/hdd/downloads'
      group = "pirates";

      dataDir = "${dataPath}/${name}";
      openFirewall = true;

      settings = {
        update = {
          # We will update Radarr through nixpkgs
          mechanism = "external";
          automatically = false;
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
