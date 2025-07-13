{ domain, dataPath, ... }:
let
  name = "qbittorrent";
  webPort = 8080;
  torrentPort = 37490;
  user = "crow";
  address = "127.0.0.1";
  subDomain = "torrents";
in
{
  imports = [
    # Creates a services options 'qbittorrent' so that we can
    # configure it like all the rest of the services
    ./option.nix
  ];
  # Open the torrent port in the firewall
  networking.firewall = {
    allowedTCPPorts = [ torrentPort ];
    allowedUDPPorts = [ torrentPort ];
  };
  # Uses the newly created service entry in 'options.nix'
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
        listenAddresses = [ "10.128.0.1" ];
        http2 = true;
        forceSSL = true;
        acmeRoot = null;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://${address}:${(builtins.toString webPort)}";
          proxyWebsockets = true;
          # Only allow people connected via Wireguard to connect
          extraConfig = ''
            allow 10.128.0.0/16;
            deny all;
          '';
        };
      };
    };
  };
}
