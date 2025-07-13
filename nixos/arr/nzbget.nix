# Ensure that you've opened port 32400 on the router
# or you won't be able to reach it externally
{ domain, dataPath, ... }:
let
  name = "nzbget";
  port = 6789;
  user = "crow";
  appDir = "${dataPath}/${name}";
  address = "127.0.0.1";
  subDomain = name;
in
{

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
        listenAddresses = [ "10.128.0.1" ];
        http2 = true;
        forceSSL = true;
        acmeRoot = null;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://${address}:${(builtins.toString port)}";
          proxyWebsockets = true;
          # Only allow people connected via Wireguard to connect
          extraConfig = ''
            allow 10.128.0.0/16;
            deny all;
            proxy_pass_header Authorization;
          '';
        };
      };
    };
  };
}
