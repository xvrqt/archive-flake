{ domain, dataPath, allow-list, interfaces, ... }:
let
  name = "qbittorrent";
  webPort = 8080;
  torrentPort = 37490;
  user = "crow";
  address = "127.0.0.1";
  subDomain = "torrents";
in
{

  users = {
    # Not a real user
    users."${name}" = {
      group = "pirates";
      isSystemUser = true;
    };
    # Allow access to the /zpools/hdd/media
    groups."media-players".members = [ "${name}" ];
  };

  # Uses the newly created service entry in 'options.nix'
  services = {
    "${name}" = {
      enable = true;
      user = user;
      # This group has access to '/zpools/hdd/media' and '/zpools/hdd/downloads'
      group = "pirates";

      webuiPort = webPort;
      torrentingPort = torrentPort;
      profileDir = "${dataPath}/${name}";
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
          proxyPass = "http://${address}:${(builtins.toString webPort)}";
          proxyWebsockets = true;
          recommendedProxySettings = true;

          # Only allow people connected via Wireguard to connect
          extraConfig = ''
            proxy_pass_header Authorization;
            proxy_ssl_server_name on;
            ${allow-list}
            deny all;
          '';
        };
      };
    };
  };

  # Open the torrent port in the firewall
  networking.firewall = {
    allowedTCPPorts = [ torrentPort ];
    allowedUDPPorts = [ torrentPort ];
  };
}
