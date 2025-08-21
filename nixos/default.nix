# NAS and Media Server
{ pkgs
, ...
}: {

  imports = [
    # Media Fetching, Cataloging, and Playback Services
    ./arr
    # The irlqt-net wiki
    ./bookstack
    # Gummi-boot setup, kernel modules, etc
    ./boot.nix
    # Setup and import zpools, boot device, unlock system device, persist data
    ./filesystems
    # Git Repositories
    ./forgejo
    # Custom Hardware Setup
    ./hardware.nix
    # NixOS Generated Hardware Setup
    ./hardware-configuration.nix
    # Immich server to sort and oragnize photos
    ./image.nix
    # Run a public Monero node to help the network
    ./monero.nix
    # Search Engine
    ./searx.nix
    # NGINX Webserver & Website Configuration
    ./web
  ];

  # Like systemPackages but more intergrated and configurable
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      shellAliases = {
        c = "clear";
        ll = "ls -l";
        vi = "nvim";
        vim = "nvim";
      };

      # ENHANCE
      ohMyZsh = {
        enable = true;
        theme = "jonathan";
        plugins = [ "git" ];
      };
    };

    # Git for maintaining Flakes
    git = {
      enable = true;
      package = pkgs.gitFull;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
