{ lib
, pkgs
, inputs
, config
, ...
}: {

  environment.systemPackages = [
    pkgs.oxipng # PNG Crusher
    pkgs.exiftool # EXIF Data Reading/Writing
    pkgs.imagemagick # Image Manipulation Program
    pkgs.immich-go
    pkgs.immich-cli
  ];

  # Ostensibly enables video rendering
  users.users.immich.extraGroups = [ "video" "render" ];
  systemd.services."immich-server".serviceConfig.PrivateDevices = lib.mkForce false;
  services = {
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
  };
}
