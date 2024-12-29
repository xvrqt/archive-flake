{
  imports = [
    # Gummi-boot setup, kernel modules, etc
    ./boot.nix
    # Setup and import zpools, boot device, unlock system device, persist data
    ./filesystems
    # Custom Hardware Setup
    ./hardware.nix
    # NixOS Generated Hardware Setup
    ./hardware-configuration.nix
  ];

  # Enable NixOS Flakes
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
   ];

   # Optimise the Nix-Store once a week
   optimise = {
     automatic = true;
     dates = [ "weekly" ];
   };

   # Automatically Clean-out the Nix-Store
   gc = {
     automatic = true;
     options = "--delete-older-than 30d";
     dates = "weekly";
   };
 };
}
