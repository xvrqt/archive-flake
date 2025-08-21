# Ensure that you've opened port 32400 on the router
# or you won't be able to reach it externally
{ domain, dataPath, allow-list, interfaces, ... }:
let
  name = "nzbget";
  port = 6789;
  user = "crow";
  appDir = "${dataPath}/${name}";
  address = "127.0.0.1";
  subDomain = name;
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

  services = {
    "${name}" = {
      enable = true;
      user = user;
      # This group has access to '/zpools/hdd/media' and '/zpools/hdd/downloads'
      group = "pirates";

      settings = {
        "MainDir" = appDir;
        "InterDir" = "${appDir}/dowloads";
        "NzbDir" = "${appDir}/nzb";
        "QueueDir" = "${appDir}/queue";
        "TempDir" = "${appDir}/tmp";
        "ScriptDir" = "${appDir}/scripts";
        "LockFile" = "${appDir}/nzbget.lock";
        #	"WebDir" = "${appDir}/web";
        "DestDir" = "/zpools/hdd/downloads/usenet";
        "RequiredDir" = "/zpools/hdd/media;/zpools/hdd/downloads/usenet;/zpools/ssd/apps/nzbget";

        # Usenet Connection Credentials
        "Server1.Name" = "NewsHosting";
        "Server1.Level" = "0";
        "Server1.Optional" = "no";
        "Server1.Host" = "news.newshosting.com";
        "Server1.Port" = "563";
        "Server1.Username" = "xxvrqt";
        "Server1.Connections" = "30";
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
            proxy_pass_header Authorization;
            proxy_ssl_server_name on;
            ${allow-list}
            deny all;
          '';
        };
      };
    };
  };
}
