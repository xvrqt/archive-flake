# NAS and Media Server
{
  pkgs,
  inputs,
  config,
  ...
}: {

  imports = [
    # monero
    ./monero.nix
    ./misskey.nix
    # Additional System Configuration: boot, hardware, filesystems
    ./nixos
    # Media Fetching, Cataloging, and Playback Services
    ./arr
    # NGINX Webserver & Website Configuration
    ./web
  ];

  # SECRETS
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/persist/sops/age/keys.txt";
  sops.secrets."cloudflare/CF_DNS_API_TOKEN" = {owner = "acme";};

  services = {
    # So I don't have to login to my own shell
    getty = {
      autologinUser = "crow";
    };

    # Start and SSH server, and set up known keys
    # Break this out, add secrets eventually
    openssh = {
      enable = true;
      ports = [ 23 ];

      settings = {
	AllowUsers = [ "crow"];	
        PasswordAuthentication = false;
	PermitRootLogin = "no";
	UseDns = true;
      };
      extraConfig = ''
        AcceptEnv GIT_PROTOCOL
      '';
    };
    # Needed by something, but I'm not sure what (arr probably?)
    xserver.videoDrivers = [ "nvidia" ];
  };

  users.groups."pirates" = {};
  users.groups."media-players" = {};
  users.groups."media-players".members = ["64600" "radarr" "sonarr" "archivist" "jellyfin" "mysql" "photoprism"];


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
        plugins = ["git"];
      };
    };

    # Git for maintaining Flakes
    git = {
      enable = true;
      #userName = "xvrqt";
      #userEmail = "git@xvrqt.com";
      package = pkgs.gitFull;
    };
  };

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    # These packages are automatically available to all users
    systemPackages = [
      # Default text editor
      pkgs.neovim
      # Pretty print system information upon shell login
      pkgs.neofetch
      # Needed to manage secrets
      pkgs.sops
      pkgs.qbittorrent-nox
      pkgs.yt-dlp
      pkgs.ffmpeg-full
      pkgs.cudatoolkit
      pkgs.xteve
      pkgs.vlc
    ];
    # Permissible login shells (sh is implicitly included)
    shells = [pkgs.zsh];
  };

  # Networking
  # Probably more specifics I can add here
  networking = {
    hostName = "archive";
    networkmanager.enable = true;
    firewall = {
      enable = false;
      allowedTCPPorts = [22 80 5055 443 3000 2049];
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
    mutableUsers = false;
    users = {
      crow = {
        # Default Shell
        shell = pkgs.zsh;
        # Not used, we're going to use home-manager for this
        packages = [pkgs.zsh];
        isNormalUser = true;
	uid = 1000;
        home = "/home/crow";
        description = "Look in a mirror";
        extraGroups = ["networkmanager" "wheel"];
        openssh = {
          authorizedKeys.keys = [
"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmS29bR+UuD0LZPXu+KuGiny4Lnf8s/bnhZBWDb7Q9H crow@xvrqt"
          ];
        };
        hashedPassword = "$y$j9T$F61RO.moSBkGAD390P2T00$gLRaqv4RSzGhuzf6jytW49TsLTxHjOPopqcKzdWAvR4";
        initialHashedPassword = "$y$j9T$F61RO.moSBkGAD390P2T00$gLRaqv4RSzGhuzf6jytW49TsLTxHjOPopqcKzdWAvR4";
      };


      root = {
        # Default Shell
        shell = pkgs.zsh;
        # Not used, we're going to use home-manager for this
        packages = [];
        # Added to the list of sudoers
        extraGroups = ["networkmanager" "wheel"];
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
