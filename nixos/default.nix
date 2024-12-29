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

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Get specific with formatting
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
}
