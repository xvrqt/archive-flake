# Ensure that you've opened port 32400 on the router
# or you won't be able to reach it externally
{ pkgs, domain, dataPath, ... }:
let
  name = "plex";
  port = 32400;
  user = name;
  address = "127.0.0.1";
  subDomain = name;
in
{

  services = {
    # Enable Plex
    plex = {
      enable = true;
      user = user;
      # This group has access to '/zpools/hdd/media' 
      group = "media-players";

      dataDir = "${dataPath}/${name}";
      openFirewall = true;
      package = pkgs.plex.override {
        plexRaw = pkgs.plexRaw.overrideAttrs (old: rec {
          pname = "plexmediaserver";
          version = "1.42.1.10060-4e8b05daf";
          src = pkgs.fetchurl {
            url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
            sha256 = "sha256:1x4ph6m519y0xj2x153b4svqqsnrvhq9n2cxjl50b9h8dny2v0is";
          };
          passthru = old.passthru // {
            inherit version;
          };
        });
      };
    };

    nginx = {
      # Setup the reverse proxy
      # Plex uses 'xvrqt.com' because it's an external facing service
      virtualHosts."plex.xvrqt.com" = {
        http2 = true;
        forceSSL = true;
        acmeRoot = null;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://${address}:${(builtins.toString port)}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
