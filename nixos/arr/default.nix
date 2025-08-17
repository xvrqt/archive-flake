# Media Fetching, Cataloging, and Playback Services
{ pkgs
, inputs
, config
, ...
}:
let
  # Where all the pirate apps will subdomain off of
  domain = "irlqt.net";
  # Where all the services will store their app data
  dataPath = "/zpools/ssd/apps";
in
{
  imports = [
    ## MEDIA STREAMING SERVICES ##
    # Plex
    (import ./plex.nix { inherit pkgs domain dataPath; })
    ## MEDIA 
    # Public media picker
    (import ./jellyseerr.nix { inherit domain; })
    # Movie indexer, downloader, organizer
    (import ./radarr.nix { inherit domain dataPath; })
    # TV Series indexer, download, organizer
    (import ./sonarr.nix { inherit domain dataPath; })
    # Sync settings between Radarr & Sonarr
    (import ./prowlarr.nix { inherit domain; })
    ## DOWNLOADERS ##
    # Usenet NXB file downloader
    (import ./nzbget.nix { inherit domain dataPath; })
    # Torrent Client & Web UI
    (import ./qbittorrent { inherit domain dataPath; })
  ];
}
