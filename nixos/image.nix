{ lib
, pkgs
, inputs
, config
, ...
}: {

  users.users.immich = {
    home = "/var/lib/immich";
    createHome = true;
  };

  # environment.sessionVariables = {
  #   "DB_SKIP_MIGRATIONS" = "true";
  # };

  environment.systemPackages = [
    pkgs.oxipng # PNG Crusher
    pkgs.exiftool # EXIF Data Reading/Writing
    pkgs.imagemagick # Image Manipulation Program

    # Easier administration from the CLI for some tasks
    pkgs.immich-go
    pkgs.immich-cli
  ];

  # Ostensibly enables video rendering
  users.users.immich.extraGroups = [ "video" "render" ];
  systemd.services."immich-server".serviceConfig.PrivateDevices = lib.mkForce false;
  services = {
    immich-public-proxy = {
      enable = true;
      port = 45541;
      openFirewall = true;
      immichUrl = "https://immich.irlqt.net";
    };

    immich = {
      enable = true;
      user = "immich";
      group = "media-players";
      host = "127.0.0.1";
      openFirewall = true;
      database.createDB = true;
      machine-learning.enable = true;
      mediaLocation = "/zpools/hdd/media/images/immich";
    };
    # postgresql = {
    #   ensureDatabases = [ "immich" ];
    # };
  };
}
