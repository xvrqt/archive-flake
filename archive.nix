# NAS and Media Server
{
  pkgs,
  inputs,
  config,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Include custom hardware configurations
    #./hardware.nix
    # Include the device to filesystem mapping
    ./filesystems.nix
    # Include the boot settings (some are auto-generated in ./hardware-configuration.nix)
    #./boot.nix
  ];

  programs.bandwhich.enable = false;


  # Persist Data
  environment.persistence."/persist" = {
    directories = [
      "/var/apps"
      "/var/www"
      "/var/log"
      "/etc/ssh"
      "/var/lib"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
      "/etc/nix/id_rsa"
      #"/etc/exports.d/zfs.exports"
    ];
  };

  # Add NixOS tooling
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services = {
    websites = {
      enable = true;
      dnsProvider = "cloudflare";
      dnsTokenFile = config.sops.secrets."cloudflare/CF_DNS_API_TOKEN".path;
      sites = {
        homepage = {
          enable = true;
          domain = "xvrqt.com";
        };
        cs4600 = {
          enable = true;
          domain = "cs4600.xvrqt.com";
        };
        moomin-orb = {
          enable = true;
          domain = "orb.xvrqt.com";
        };
        game-of-life = {
          enable = true;
          domain = "gol.xvrqt.com";
        };
        graphics = {
          enable = true;
          domain = "graphics.xvrqt.com";
        };
      };
    };

    xserver.videoDrivers = ["nvidia"];
    #    forgejo = {
    #      enable = true;
    #      stateDir = "/var/apps/forgejo";
    #      settings = {
    #	service = {
    #	  DISABLE_REGISTRATION = true;
    #	};
    #        server = {};
    #      };
    #    };

    # So I don't have to login to my own shell
    getty = {
      autologinUser = "archivist";
    };

    # Start and SSH server, and set up known keys
    # Break this out, add secrets eventually
    openssh = {
      enable = true;
      ports = [ 23 ];

      settings = {
	AllowUsers = [ "archivist" "amy" "xvrqt" "crow"];	
        PasswordAuthentication = false;
	PermitRootLogin = "no";
	UseDns = true;
      };
      extraConfig = ''
        AcceptEnv GIT_PROTOCOL
      '';
    };

    # Plex bby
    plex = {
      enable = true;
      dataDir = "/var/apps/plex";
      user = "plex";
      group = "media-players";
      openFirewall = true;
    };

    prowlarr = {
      enable = true;
      #user = "archivist";
      #group = "pirates";
      openFirewall = true;
      #dataDir = "/zpools/ssd/apps/prowlarr";
    };

    nzbget = {
      enable = true;
      user = "archivist";
      group = "pirates";
      settings = {
        "MainDir" = "/zpools/ssd/apps/nzbget";
        "DestDir" = "/zpools/hdd/downloads/usenet";
        "InterDir" = "/zpools/ssd/apps/nzbget/dowloads";
        "NzbDir" = "/zpools/ssd/apps/nzbget/nzb";
        "QueueDir" = "/zpools/ssd/apps/nzbget/queue";
        "TempDir" = "/zpools/ssd/apps/nzbget/tmp";
        #	"WebDir" = "/zpools/ssd/apps/nzbget/web";
        "ScriptDir" = "/zpools/ssd/apps/nzbget/scripts";
        "LockFile" = "/zpools/ssd/apps/nzbget/nzbget.lock";
        "RequiredDir" = "/zpools/hdd/media;/zpools/hdd/downloads/usenet;/zpools/ssd/apps/nzbget";

        "Server1.Name" = "NewsHosting";
        "Server1.Level" = "0";
        "Server1.Optional" = "no";
        "Server1.Host" = "news.newshosting.com";
        "Server1.Port" = "563";
        "Server1.Username" = "xxvrqt";
        "Server1.Connections" = "30";
      };
    };

    jellyseerr = {
      enable = true;
      openFirewall = true;
    };

    radarr = {
      enable = true;
      user = "archivist";
      group = "pirates";
      openFirewall = true;
      dataDir = "/zpools/ssd/apps/radarr";
    };

    sonarr = {
      enable = true;
      user = "archivist";
      group = "pirates";
      openFirewall = true;
      dataDir = "/zpools/ssd/apps/sonarr";
    };

    # Reverse Proxy
    nginx = {

      virtualHosts."irlqt.me" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          root = "/var/www/irlqt";
        };
      };

      virtualHosts."photos.irlqt.me" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        http2 = true;
        extraConfig = ''
           	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Host $host;
          proxy_buffering off;
          proxy_http_version 1.1;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:2342";
          proxyWebsockets = true;
        };
      };

      virtualHosts."webgl.irlqt.me" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          root = "/var/www/webgl";
        };
      };
      virtualHosts."qbittorrent.irlqt.me" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          proxyWebsockets = true;
        };
      };
      virtualHosts."jellyseerr.irlqt.me" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:5055";
          proxyWebsockets = true;
        };
      };
      virtualHosts."radarr.irlqt.me" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:7878";
          proxyWebsockets = true;
        };
      };
      virtualHosts."sonarr.irlqt.me" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8989";
          proxyWebsockets = true;
        };
      };
      virtualHosts."plex.irlqt.me" = {
        forceSSL = true;
        http2 = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:32400";
          proxyWebsockets = true;
        };
      };
      virtualHosts."jellyfin.irlqt.me" = {
        forceSSL = true;
        http2 = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
          proxyWebsockets = true;
        };
      };
      virtualHosts."prowlarr.irlqt.me" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:9696";
          proxyWebsockets = true;
        };
      };
      virtualHosts."nzbget.irlqt.me" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:6789";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_pass_header Authorization;
          '';
        };
      };
    };
  };

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/persist/sops/age/keys.txt";
  sops.secrets."cloudflare/CF_DNS_API_TOKEN" = {owner = "acme";};

  users.groups."pirates" = {};
  users.groups."media-players" = {};
  users.groups."media-players".members = ["64600" "radarr" "sonarr" "archivist" "jellyfin" "mysql" "photoprism"];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  # GPU

  #  nixpkgs.config.packageOverrides = pkgs: {
  #  	vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  #  };
  hardware = {
    nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
      open = false;
    };
    graphics = {
      enable = true;
      #driSupport = true;
      #driSupport32Bit = true;
      extraPackages = [
        pkgs.intel-compute-runtime
        pkgs.vaapiIntel
        pkgs.intel-media-driver
        pkgs.vaapiVdpau
        pkgs.libvdpau-va-gl
      ];
    };
  };

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
      # pkgs.photoprism
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
      archivist = {
        # Default Shell
        shell = pkgs.zsh;
        # Not used, we're going to use home-manager for this
        packages = [pkgs.zsh];
        isNormalUser = true;
        home = "/home/archivist";
        description = "Primary maintainer of the archives";
        extraGroups = ["networkmanager" "wheel"];
        openssh = {
          authorizedKeys.keys = [
# "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDqLgLiHG41aIfL6Zza5sDOTbVuTPlqjVmBLe3yyI5YG3yqyZZXBHxI8bZ7cx+yDLDvRorhomsJnaCu9hvWF3O+7OQiKe9k54Lb3HTbJOjA2vegu2p8o422fxpcSQWoeDguRBi09Qtf4zRtpjPxUPJB+uhBprJbrFSdduV6IPGass2iNSHWQL2bnWz8/bKA4MvImWmTCJhIGK/uKl6qpL211Ah2wkwgW4Qu5QUHfS7GWHEsA/fs+wY+W5n0RfdnG6LlZdTilZhJDepAZsfliDIrZsl7Tr+HXXmnzCUNF9YvydeCLNri7b/dHBUo0u9rInQ/2NyqxJ7JqxDYhYSh3qgz3gCldCeouAl0Bri1uQmmLLfm7Beg+ggck+WF2gMmOI5pPXIS1DtQ6VYvrT6o/1r24+gPXhCyNiXvD6lh3cE6O+PjN5B0OsACKNyg680e14StVpuUVhJYwkaTryRkAXt1OKz24vHfbCQo9HEvHkBIV+m2zMJ3faR9aqgeu5jVGmOYq5XC+tUv1DTS0uMc6Zi3ug0jui2zYh8u/AD6GrrxppSlov3rrjdIIOGwwU7xzucUu4goSIhejpjlA8vVXLVk9sisnrC3yXsgsMZfXVBiR/fYxZILQyUFiar0Np6h6OX3nAcfcINJrc1a1ilZoxKxf1uAsa5T5DgRQF1QnCNjtw== openpgp:0xC37D5C68"
"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDqLgLiHG41aIfL6Zza5sDOTbVuTPlqjVmBLe3yyI5YG3yqyZZXBHxI8bZ7cx+yDLDvRorhomsJnaCu9hvWF3O+7OQiKe9k54Lb3HTbJOjA2vegu2p8o422fxpcSQWoeDguRBi09Qtf4zRtpjPxUPJB+uhBprJbrFSdduV6IPGass2iNSHWQL2bnWz8/bKA4MvImWmTCJhIGK/uKl6qpL211Ah2wkwgW4Qu5QUHfS7GWHEsA/fs+wY+W5n0RfdnG6LlZdTilZhJDepAZsfliDIrZsl7Tr+HXXmnzCUNF9YvydeCLNri7b/dHBUo0u9rInQ/2NyqxJ7JqxDYhYSh3qgz3gCldCeouAl0Bri1uQmmLLfm7Beg+ggck+WF2gMmOI5pPXIS1DtQ6VYvrT6o/1r24+gPXhCyNiXvD6lh3cE6O+PjN5B0OsACKNyg680e14StVpuUVhJYwkaTryRkAXt1OKz24vHfbCQo9HEvHkBIV+m2zMJ3faR9aqgeu5jVGmOYq5XC+tUv1DTS0uMc6Zi3ug0jui2zYh8u/AD6GrrxppSlov3rrjdIIOGwwU7xzucUu4goSIhejpjlA8vVXLVk9sisnrC3yXsgsMZfXVBiR/fYxZILQyUFiar0Np6h6OX3nAcfcINJrc1a1ilZoxKxf1uAsa5T5DgRQF1QnCNjtw== (none)"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHwADqdlJDCVqPpOExyye9ky6c/VOaTYOZ+t9dnLKf6i archivist"
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
