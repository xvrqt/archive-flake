# Ensure that you've opened port 32400 on the router
# or you won't be able to reach it externally
{ domain, dataPath, allow-list, interfaces, ... }:
let
  name = "slsk";
  user = name;

  port = 6677;
  address = "127.0.0.1";
  subDomain = name;
in
{

  users = {
    # Not a real user
    users."${name}" = {
      isSystemUser = true;
      group = "pirates";
    };
    # Allow access to the /zpools/hdd/media
    groups."media-players".members = [ "${name}" ];
  };

  services = {
    "${name}d" = {
      enable = true;
      # Create a separate user for radarr for security reasons
      user = user;
      # This group has access to '/zpools/hdd/media' and '/zpools/hdd/downloads'
      group = "pirates";

      domain = "${subDomain}.${domain}";
      openFirewall = true;

      settings = {
        web = {
          inherit port;
        };

        shares = {
          directories = [ "/zpools/hdd/media/music" ];
        };

        directories = {
          downloads = "/zpools/hdd/downloads/slsk";
          incomplete = "/zpools/hdd/downloads/slsk/incomplete";
        };

        soulseek = {
          # Listen for incoming connections
          listen_port = 51444;
          # User description
          description = "Not Dead Yet!";
        };
      };

      # I HATE WHEN THEY BUNDLE THIS SHIT
      nginx = {
        # Setup the reverse proxy
        serverName = "${subDomain}.${domain}";
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

  #   nginx = {
  #     # Setup the reverse proxy
  #     virtualHosts."${subDomain}.${domain}" = {
  #       # Only listen on private interfaces
  #       listenAddresses = interfaces;

  #       http2 = true;
  #       forceSSL = true;
  #       acmeRoot = null;
  #       enableACME = true;

  #       locations."/" = {
  #         proxyPass = "http://${address}:${(builtins.toString port)}";
  #         proxyWebsockets = true;
  #         recommendedProxySettings = true;

  #         extraConfig = ''
  #           proxy_ssl_server_name on;
  #           ${allow-list}
  #           deny all;
  #         '';
  #       };
  #     };
  #   };
  # };
}
