# NGINX Reverse Proxies for Services
# TODO: Move these to where they live
{
  pkgs,
  config,
  inputs,
  ...
}: let 
in {
  services = {
    nginx = {
      virtualHosts."qbittorrent.irlqt.me" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          proxyWebsockets = true;
        };
      };
      virtualHosts."jellyseerr.irlqt.me" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:5055";
          proxyWebsockets = true;
        };
      };
      virtualHosts."radarr.irlqt.me" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:7878";
          proxyWebsockets = true;
        };
      };
      virtualHosts."sonarr.irlqt.me" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8989";
          proxyWebsockets = true;
        };
      };
      virtualHosts."plex.irlqt.me" = {
        forceSSL = true;
        http2 = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:32400";
          proxyWebsockets = true;
        };
      };
      virtualHosts."jellyfin.irlqt.me" = {
        forceSSL = true;
        http2 = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
          proxyWebsockets = true;
        };
      };
      virtualHosts."prowlarr.irlqt.me" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:9696";
          proxyWebsockets = true;
        };
      };
      virtualHosts."nzbget.irlqt.me" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:6789";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_pass_header Authorization;
          '';
        };
      };
    };
  };
}
