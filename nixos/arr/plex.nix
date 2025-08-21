# Ensure that you've opened port 32400 on the router
# or you won't be able to reach it externally
{ pkgs, domain, dataPath, allow-list, interfaces, ... }:
let
  name = "plex";
  user = name;

  port = 32400;
  address = "127.0.0.1";
  subDomain = name;
in
{
  # Not a real user
  users.users."${name}".isSystemUser = true;

  # Prioritize Plex I/O
  systemd.services.plex.serviceConfig.IOSchedulingPriority = 0;

  services = {
    # Enable Plex
    plex = {
      enable = true;
      # Create a separate user for Plex for security reasons
      user = user;
      # This group has access to '/zpools/hdd/media' 
      group = "media-players";

      # Store application data on the SSD
      dataDir = "${dataPath}/${name}";
      openFirewall = true;

      # Allow use of all hardware
      accelerationDevices = [ "*" ];

      # Temporary workaround until the mirror works again after Plex gets its security patched
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

    # Setup the reverse proxy to pass requests through to
    nginx = {
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
