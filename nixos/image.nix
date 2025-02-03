{
  pkgs,
  inputs,
  config,
  ...
}: {

environment.systemPackages = [
	pkgs.oxipng # PNG Crusher
	pkgs.exiftool # EXIF Data Reading/Writing
	pkgs.imagemagick # Image Manipulation Program
	pkgs.immich-go
	pkgs.immich-cli
];

users.users.immich.extraGroups = [ "video" "render" ];
services = {
	immich = {
		host = "127.0.0.1";
		enable = true;
		user = "immich";
		group = "media-players";
		openFirewall = true;
		database.createDB = true;
		machine-learning.enable = true;
		mediaLocation = "/zpools/hdd/media/images/immich";

	};
};
}
