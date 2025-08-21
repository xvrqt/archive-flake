{ domain, dataPath, allow-list, interfaces, ... }:
let
  name = "jellyseerr";
  port = 5055;
  address = "127.0.0.1";
  subDomain = name;
in
{
  users = {
    users."${name}" = {
      # Allow access to the /zpools/hdd/media
      group = "media-players";
      # Not a real user
      isSystemUser = true;
    };
  };

  systemd.services.jellyseerr = {
    serviceConfig = {
      ReadWritePaths = "${dataPath}/${name}";
    };
  };

  services = {

    jellyseerr = {
      enable = true;
      configDir = "${dataPath}/${name}";

      inherit port;
      openFirewall = true;
    };

    nginx = {
      virtualHosts."${subDomain}.${domain}" = {
        # Only listen on private interfaces
        listenAddresses = interfaces;

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
