{ lib, config, domain, dataPath, allow-list, interfaces, ... }:
let
  name = "prowlarr";
  port = 9696;
  address = "127.0.0.1";
  dataDir = "${dataPath}/${name}";
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

  # Change where prowlarr keeps it state to the dataDir with everyone else
  systemd.services."${name}" = {
    serviceConfig = {
      StateDirectory = lib.mkForce "${dataDir}";
      ExecStart = lib.mkForce "${lib.getExe config.services.prowlarr.package} -nobrowser -data=${dataDir}";
      ReadWritePaths = "${dataDir}";
    };
  };

  services = {

    "${name}" = {
      enable = true;
      openFirewall = true;

      settings = {
        server = {
          inherit port;
        };

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
