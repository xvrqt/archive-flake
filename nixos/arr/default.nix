# Media Fetching, Cataloging, and Playback Services
{ lib
, pkgs
, config
, inputs
, machine
, ...
}:
let
  # Where all the pirate apps will subdomain off of
  domain = "irlqt.net";
  # Where all the services will store their app data
  dataPath = "/zpools/ssd/apps";

  machines = inputs.networking.config.machines;
  # Only machines I control on the tailnet are allowed
  allowed-ips = [
    machines.nyaa.ip.v4.tailnet
    machines.spark.ip.v4.tailnet
    machines.archive.ip.v4.tailnet
    machines.thirdlobe.ip.v4.tailnet
    machines.lighthouse.ip.v4.tailnet
    # The entire amy-net is a trusted interface
    "10.128.0.0/9"
  ];
  # Create an NGINX config for allowing only certain IPs
  allow-amy-only = (lib.concatLines (map (ip: "allow ${ip};") allowed-ips));
  allow-secure-interfaces-only = ''
    allow 10.128.0.0/9;
    allow 100.64.0.0/10;
  '';

  amy-net-interface-ip = machines.${machine}.ip.v4.wg;
  irlqt-net-interface-ip = machines.${machine}.ip.v4.tailnet;
  private-interfaces = [ amy-net-interface-ip irlqt-net-interface-ip ];
in
{
  imports = [
    ## MEDIA STREAMING SERVICES ##
    # Plex
    (import ./plex.nix { inherit pkgs domain dataPath; allow-list = allow-secure-interfaces-only; interfaces = private-interfaces; })
    # Public media picker
    (import ./jellyfin.nix { inherit domain dataPath; allow-list = allow-secure-interfaces-only; interfaces = private-interfaces; })
    # Music Server
    (import ./navidrome.nix { inherit domain dataPath; allow-list = allow-secure-interfaces-only; interfaces = private-interfaces; })
    ## MEDIA 
    # Public media picker
    (import ./jellyseerr.nix { inherit domain dataPath; allow-list = allow-secure-interfaces-only; interfaces = private-interfaces; })
    # Movie indexer, downloader, organizer
    (import ./radarr.nix { inherit domain dataPath; allow-list = allow-amy-only; interfaces = private-interfaces; })
    # TV Series indexer, download, organizer
    (import ./sonarr.nix { inherit domain dataPath; allow-list = allow-amy-only; interfaces = private-interfaces; })
    # Music indexer, downloader, organizer
    (import ./lidarr.nix { inherit domain dataPath; allow-list = allow-amy-only; interfaces = private-interfaces; })
    # Music P2P Daemon TODO: Add EnvFile
    # (import ./slskd.nix { inherit domain dataPath; allow-list = allow-amy-only; interfaces = private-interfaces; })
    # Sync settings between Radarr & Sonarr
    (import ./prowlarr.nix { inherit lib config domain dataPath; allow-list = allow-amy-only; interfaces = private-interfaces; })

    ## DOWNLOADERS ##
    # Usenet NXB file downloader
    (import ./nzbget.nix { inherit domain dataPath; allow-list = allow-amy-only; interfaces = private-interfaces; })
    # Torrent Client & Web UI
    (import ./qbittorrent.nix { inherit domain dataPath; allow-list = allow-amy-only; interfaces = private-interfaces; })
  ];

  services = {
    # Helps some programs get access to the video card for transcoding
    xserver.videoDrivers = [ "nvidia" ];
  };

  environment.systemPackages = [
    # Some programs need this to use the P2000 Quadro card for transcoding
    pkgs.cudatoolkit
    # Used for music tagging
    pkgs.beets
  ];

  # Create a new group for daemon 'users' which can download, and organize media
  users.groups."pirates" = { };
  # Create a new group for daemon 'users' which can organize, and playback media
  users.groups."media-players" = { };
}
