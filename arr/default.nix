# Media Fetching, Cataloging, and Playback Services
{
  pkgs,
  inputs,
  config,
  ...
}: {
  services = {
    # Media Playback Service (slowly becoming evil)
    plex = {
      enable = true;
      dataDir = "/var/apps/plex";
      user = "plex";
      group = "media-players";
      openFirewall = true;
    };

    jellyfin = {
      enable = true;
      openFirewall = true;
    };

    # Search for new shows and media
    jellyseerr = {
      enable = true;
      openFirewall = true;
    };

    radarr = {
      enable = true;
      user = "archivist";
      group = "pirates";
      openFirewall = true;
      dataDir = "/zpools/ssd/apps/radarr";
    };

    sonarr = {
      enable = true;
      user = "archivist";
      group = "pirates";
      openFirewall = true;
      dataDir = "/zpools/ssd/apps/sonarr";
    };
    # Sync settings between Radarr & Sonarr
    prowlarr = {
      enable = true;
      #user = "archivist";
      #group = "pirates";
      openFirewall = true;
      #dataDir = "/zpools/ssd/apps/prowlarr";
    };

    nzbget = {
      enable = true;
      user = "archivist";
      group = "pirates";
      settings = {
        "MainDir" = "/zpools/ssd/apps/nzbget";
        "DestDir" = "/zpools/hdd/downloads/usenet";
        "InterDir" = "/zpools/ssd/apps/nzbget/dowloads";
        "NzbDir" = "/zpools/ssd/apps/nzbget/nzb";
        "QueueDir" = "/zpools/ssd/apps/nzbget/queue";
        "TempDir" = "/zpools/ssd/apps/nzbget/tmp";
        #	"WebDir" = "/zpools/ssd/apps/nzbget/web";
        "ScriptDir" = "/zpools/ssd/apps/nzbget/scripts";
        "LockFile" = "/zpools/ssd/apps/nzbget/nzbget.lock";
        "RequiredDir" = "/zpools/hdd/media;/zpools/hdd/downloads/usenet;/zpools/ssd/apps/nzbget";

        "Server1.Name" = "NewsHosting";
        "Server1.Level" = "0";
        "Server1.Optional" = "no";
        "Server1.Host" = "news.newshosting.com";
        "Server1.Port" = "563";
        "Server1.Username" = "xxvrqt";
        "Server1.Connections" = "30";
      };
    };
 };
}
