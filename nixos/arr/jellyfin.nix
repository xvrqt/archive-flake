{ domain, dataPath, allow-list, interfaces, ... }:
let
  name = "jellyfin";
  port = 8096;
  address = "127.0.0.1";
  subDomain = name;
in
{
  users = {
    users."${name}" = {
      # Not a real user
      isSystemUser = true;
    };
  };

  # systemd.services.jellyseerr = {
  #   serviceConfig = {
  #     ReadWritePaths = "${dataPath}/${name}";
  #   };
  # };

  services = {

    "${name}" = {
      enable = true;

      user = "${name}";
      group = "media-players";

      dataDir = "/${dataPath}/${name}";
      logDir = "${dataPath}/${name}/logs";
      cacheDir = "${dataPath}/${name}/cache";
      configDir = "${dataPath}/${name}/config";

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
