# NAS and Media Server
{ lib
, pkgs
, inputs
, config
, ...
}: {

  imports = [
    # Media Fetching, Cataloging, and Playback Services

    ./arr
    # ./bookstack
    ./cryptpad.nix
    # NGINX Webserver & Website Configuration
    ./web
    # Running a Monero node to help the network :]
    # ./monero.nix
    # Configure and run a Misskey social network
    ./misskey.nix
    # Immich server to sort and oragnize photos
    ./image.nix
    # I2P Mix-Overlay Network
    # ./i2p.nix
    # Mesh Network
    # ./reticulum.nix
    # ./conduwuit
    ./forgejo
    # Run an instance of peer tube
    #./peertube.nix
    #./next-cloud.nix
    # Run a DNS
    ./dns.nix
    # Search Engine
    ./searx.nix
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
  # TODO: Move to the website-flake eventually
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/persist/sops/age/keys.txt";
  sops.secrets."cloudflare/CF_DNS_API_TOKEN" = { owner = "acme"; };

  services = {

    # Needed by something, but I'm not sure what (arr probably?)
    xserver.videoDrivers = [ "nvidia" ];
  };

  users.groups."pirates" = { };
  users.groups."media-players" = { };
  users.groups."media-players".members = [ "64600" "radarr" "sonarr" "archivist" "jellyfin" "mysql" ];

  # Like systemPackages but more intergrated and configurable
  programs = {
    # Default Shell
    dtool.enable = false;
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

  environment = {
    variables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };
    # These packages are automatically available to all users
    systemPackages = [
      # Default text editor
      pkgs.neovim
      # Pretty print system information upon shell login
      pkgs.neofetch
      # Needed to manage secrets
      pkgs.sops
      pkgs.exfatprogs
      pkgs.exfat
      pkgs.qbittorrent-nox
      pkgs.yt-dlp
      pkgs.ffmpeg-full
      pkgs.cudatoolkit
    ];
    # Permissible login shells (sh is implicitly included)
    shells = [ pkgs.zsh ];
  };

  networking = {
    hostName = "archive";
    networkmanager.enable = true;
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    firewall = {
      enable = true;
      allowedUDPPorts = [ 4444 4447 5349 53 5350 32400 7070 8484 8383 9292 ];
      allowedTCPPorts = [ 23 22 80 53 8448 3478 3479 5055 443 4444 4447 9292 3000 2049 18080 3333 5555 7777 9000 32400 8383 8484 7070 ];
    };
  };

  # Security
  security = {
    sudo = {
      enable = true;
      # Don't challenge memebers of 'wheel'
      wheelNeedsPassword = false;
    };
  };

  users = {
    # Users & Groups reset on system activation, cannot be changed while running
    # mutableUsers = false;
    users = {
      #   crow = {
      #     # Default Shell
      #     shell = pkgs.zsh;
      #     # Not used, we're going to use home-manager for this
      #     packages = [ pkgs.zsh ];
      #     isNormalUser = true;
      #     uid = 1000;
      #     home = "/home/crow";
      #     description = "Look in a mirror";
      #     extraGroups = [ "networkmanager" "wheel" ];
      #     openssh = {
      #       authorizedKeys.keys = [
      #         "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmS29bR+UuD0LZPXu+KuGiny4Lnf8s/bnhZBWDb7Q9H crow@xvrqt"
      #       ];
      #     };
      #     hashedPassword = "$y$j9T$F61RO.moSBkGAD390P2T00$gLRaqv4RSzGhuzf6jytW49TsLTxHjOPopqcKzdWAvR4";
      #     initialHashedPassword = "$y$j9T$F61RO.moSBkGAD390P2T00$gLRaqv4RSzGhuzf6jytW49TsLTxHjOPopqcKzdWAvR4";
      #   };


      root = {
        # Default Shell
        shell = pkgs.zsh;
        # Not used, we're going to use home-manager for this
        packages = [ ];
        # Added to the list of sudoers
        extraGroups = [ "networkmanager" "wheel" ];
        # Disable logging in as root
        hashedPassword = "!";
        initialHashedPassword = "!";
      };
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
