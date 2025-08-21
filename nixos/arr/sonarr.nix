# Ensure that you've opened port 32400 on the router
# or you won't be able to reach it externally
{ domain, dataPath, allow-list, interfaces, ... }:
let
  name = "sonarr";
  port = 8989;
  user = "crow";
  address = "127.0.0.1";
  subDomain = name;
in
{
  users = {
    # Allow access to the /zpools/hdd/media
    groups."media-players".members = [ "${name}" ];

    # Not a real user
    users."${name}" = {
      group = "pirates";
      isSystemUser = true;
    };
  };

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
          # Only allow people connected via Wireguard to connect
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
