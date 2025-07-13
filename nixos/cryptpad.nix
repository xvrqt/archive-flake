# Ensure that you've opened port 32400 on the router
# or you won't be able to reach it externally
{ lib, ... }:
let
  name = "cryptpad";
  port = 11223;
  user = "crow";
  address = "127.0.0.1";
  domain = "irlqt.net";
  subDomain = name;
in
{

  users.groups.searx.members = [ "nginx" ];
  networking.firewall.allowedTCPPorts = [ port 11224 ];
  services = {
    "${name}" = {
      enable = true;
      settings = {
        httpPort = port;
        websocketPort = 11224;
        maxUploadSize = 1024 * 1024 * 100;
        # configureNginx = true;
        httpSafeOrigin = "https://cryptpad-sandbox.irlqt.net";
        httpUnsafeOrigin = "https://cryptpad.irlqt.net";
      };
    };

    nginx = {
      # Setup the reverse proxy
      virtualHosts."${subDomain}.${domain}" = {
        serverName = "cryptpad.irlqt.net";
        listenAddresses = [ "10.128.0.1" ];

        http2 = true;
        forceSSL = true;
        acmeRoot = null;
        enableACME = true;

        extraConfig = ''
          add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        '';

        locations."/" = {
          proxyPass = "http://${address}:${(builtins.toString port)}";
          # proxyPass = "http://${address}:3003";
          proxyWebsockets = true;
          # Only allow people connected via Wireguard to connect
          # extraConfig = ''
          #       allow 10.128.0.0/9;
          #       deny all;
          #   proxy_set_header      X-Real-IP $remote_addr;
          #   proxy_set_header      Host $host;
          #   proxy_set_header      X-Forwarded-For $proxy_add_x_forwarded_for;
          #   client_max_body_size  150m;

          #   proxy_http_version    1.1;
          #   proxy_set_header      Upgrade $http_upgrade;
          #   proxy_set_header      Connection upgrade;
          # '';
        };
        locations."^~ /cryptpad_websocket" = {
          proxyPass = "http://${address}:11224";
          proxyWebsockets = true;
          # Only allow people connected via Wireguard to connect
          # extraConfig = ''
          #   allow 10.128.0.0/9;
          #   deny all;
          #   proxy_set_header      X-Real-IP $remote_addr;
          #   proxy_set_header      Host $host;
          #   proxy_set_header      X-Forwarded-For $proxy_add_x_forwarded_for;

          #   proxy_http_version    1.1;
          #   proxy_set_header      Upgrade $http_upgrade;
          #   proxy_set_header      Connection upgrade;
          # '';
        };
      };
      # Setup the reverse proxy
      virtualHosts."cryptpad-sandbox.${domain}" = {
        http2 = true;
        forceSSL = true;
        acmeRoot = null;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://${address}:${(builtins.toString port)}";
          proxyWebsockets = true;
          # Only allow people connected via Wireguard to connect
          extraConfig = ''
          '';
        };
        locations."/cryptpad_websocket" = {
          proxyPass = "http://${address}:11224";
          proxyWebsockets = true;
          # Only allow people connected via Wireguard to connect
          extraConfig = ''
          '';
        };
      };
    };
  };
}
