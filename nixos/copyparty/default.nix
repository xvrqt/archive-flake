{ pkgs, inputs, config, ... }:
let
  port = 9001;
  address = "127.0.0.1";
  domain = "irlqt.net";
  subDomain = "copyparty";

  # Override the default package with some optionals enabled
  package = inputs.copyparty.packages.${pkgs.system}.copyparty.override {
    withHashedPasswords = true;
    withThumbnails = true;
    withFastThumbnails = true;
    withMediaProcessing = true;
    withBasicAudioMetadata = true;
    withZeroMQ = true;

    withSMB = false;
    withFTPS = false;
    withCertgen = false;
  };

  machine = inputs.networking.config.machines.archive;
  # Create an NGINX config for allowing only certain IPs
  allow-list = ''
    allow 10.128.0.0/9;
    allow 100.64.0.0/10;
  '';

  # Have NGINX only listen on certain interfaces
  amy-net-interface-ip = machine.ip.v4.wg;
  irlqt-net-interface-ip = machine.ip.v4.tailnet;
  interfaces = [ amy-net-interface-ip irlqt-net-interface-ip ];

  # Convenince paths for volumes
  crow-path = "/zpools/ssd/xvrqt";
  media-path = "/zpools/hdd/media";
  images-path = "${media-path}/images";
  copyparty-path = "/zpools/hdd/apps/copyparty";

  # Convenience settings for volumes
  readonly-access = {
    A = [ "crow" ];
    r = "*";
  };
  crow-access = {
    A = [ "crow" ];
  };
  upload-access = {
    A = [ "crow" ];
    rw = "*";
  };
  default-flags = {
    # "fk" enables filekeys (necessary for upget permission) (4 chars long)
    fk = 4;
    # scan for new files every 60sec
    scan = 60;
    # volflag "e2d" enables the uploads database
    e2d = true;
    # "d2t" disables multimedia parsers (in case the uploads are malicious)
    d2t = false;
  };
  # Index with music tagging on startup
  music-flags = {
    # "fk" enables filekeys (necessary for upget permission) (4 chars long)
    fk = 4;
    # scan for new files every 60sec
    scan = 60;
    # volflag "e2d" enables the uploads database
    e2dsa = true;
    e2ts = true;
    # "d2t" disables multimedia parsers (in case the uploads are malicious)
    d2t = false;
  };
in
{
  # Allow access to the /zpools/hdd/media
  users.groups."media-players".members = [ "copyparty" ];

  services = {
    copyparty = {
      enable = true;
      inherit package;

      settings = {
        # Interfaces (localhost because we will reverse proxy down below)
        i = address;
        # Ports
        p = [ port ];
        # Enable using a reverse proxy
        rproxy = 1;
        # Hash passwords before writing them to the config file jfc
        ah-alg = "argon2";
        # Store the database indices on the SSD
        # This makes indexing MUCH faster
        hist = "/zpools/ssd/apps/copyparty/database";
        # Auto-login the crow
        ipu = "100.64.0.4/32=crow";
        # Use all cores
        # j0 = true;
      };

      globalExtraConfig = ''
        ipu: 100.64.0.3/32=crow
        ipu: 100.64.0.2/32=crow
        ipu: 100.64.0.1/32=crow
        ipu: 100.64.0.8/32=crow
      '';

      # Users
      accounts = {
        crow.passwordFile = config.age.secrets.copyparty_crow_pw.path;
      };

      # Volumes
      volumes = {
        "/" = {
          path = "${copyparty-path}";

          access = readonly-access;
          flags = default-flags;
        };
        # Temporary storage, deletes after a day
        "/scratch" = {
          path = "${copyparty-path}/scratch";

          access = {
            A = [ "crow" ];
            rmG = "*";
          };
          flags = {
            # "fk" enables filekeys (necessary for upget permission) (4 chars long)
            fk = 4;
            # scan for new files every 60sec
            scan = 60;
            # volflag "e2d" enables the uploads database
            e2dsa = true;
            e2ts = true;
            # "d2t" disables multimedia parsers (in case the uploads are malicious)
            d2t = false;
            # Delete after a day
            lifetime = 60 * 60 * 24;
            # Max size of 100GiB
            vmaxb = "100g";
            # Max number of files is 10,000
            vmaxn = "10k";
            # Each IP can only upload 1k files per hour
            maxn = "1024,3600";
            # Each IP can only upload 5GiB per 5 min
            maxb = "5g,300";
          };
        };

        # Crow Directory
        "/crow" = {
          path = "${crow-path}";

          access = crow-access;
          flags = default-flags;
        };
        # Share my media with people
        "/media/movies/archive" = {
          path = "${media-path}/movies";

          access = readonly-access;
          flags = default-flags;
        };
        "/media/movies" = {
          path = "${copyparty-path}/media/movies";

          access = upload-access;
          flags = default-flags;
        };
        # Share my media with people
        "/media/series/archive" = {
          path = "${media-path}/series";

          access = readonly-access;
          flags = default-flags;
        };

        # Media where everyone can contribute and share
        "/media/series" = {
          path = "${copyparty-path}/media/series";

          access = upload-access;
          flags = default-flags;
        };
        "/media/images" = {
          path = "${copyparty-path}/media/images";

          access = readonly-access;
          flags = default-flags;
        };
        "/media/images/memes" = {
          path = "${images-path}/memes";

          access = upload-access;
          flags = default-flags;
        };
        # Share my media with people
        "/media/music/archive" = {
          path = "${media-path}/music";

          access = readonly-access;
          flags = music-flags;
        };
        "/media/music" = {
          path = "${copyparty-path}/media/music";

          access = upload-access;
          flags = music-flags;
        };
        # # Share my media with people
        # "/media/movies/crow" = {
        #   path = "${media-path}/movies";

        #   access = readonly-access;
        #   flags = default-flags;
        # };
        "/media/papers" = {
          path = "${copyparty-path}/media/papers";

          access = upload-access;
          flags = default-flags;
        };
        "/media/images/discord/" = {
          path = "${images-path}/discord";

          access = readonly-access;
          flags = default-flags;
        };
        "/media/images/art/archive" = {
          path = "${images-path}/art";

          access = readonly-access;
          flags = default-flags;
        };
        "/media/images/art" = {
          path = "${copyparty-path}/media/images/art";

          access = upload-access;
          flags = default-flags;
        };
        "/media/images/pixel-art/archive" = {
          path = "${images-path}/art/pixel_art";

          access = readonly-access;
          flags = default-flags;
        };
        "/media/images/pixel-art" = {
          path = "${copyparty-path}/media/images/pixel-art";

          access = upload-access;
          flags = default-flags;
        };
        "/media/images/reaction-images/archive" = {
          path = "${images-path}/reaction_images";

          access = readonly-access;
          flags = default-flags;
        };
        "/media/images/reaction-images" = {
          path = "${copyparty-path}/media/images/reaction-images";

          access = upload-access;
          flags = default-flags;
        };
        "/media/images/gifs/archive" = {
          path = "${images-path}/gifs";

          access = readonly-access;
          flags = default-flags;
        };
        "/media/images/gifs" = {
          path = "${copyparty-path}/media/images/gifs";

          access = upload-access;
          flags = default-flags;
        };


        "/media/images/emojis/archive" = {
          path = "${images-path}/emojis";

          access = readonly-access;
          flags = music-flags;
        };
        "/media/images/emojis" = {
          path = "${copyparty-path}/media/images/emojis";

          access = upload-access;
          flags = default-flags;
        };
        "/media/books" = {
          path = "${copyparty-path}/media/books";

          access = upload-access;
          flags = default-flags;
        };
      };
      openFilesLimit = 8192;
    };

    # Setup a reverse proxy
    nginx = {
      # Setup the reverse proxy
      virtualHosts."${subDomain}.${domain}" = {
        # Only listen on private interfaces
        listenAddresses = interfaces;

        http2 = true;
        forceSSL = true;
        acmeRoot = null;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://${address}:${(builtins.toString port)}";
          proxyWebsockets = true;
          # recommendedProxySettings = true;

          extraConfig = ''
                # Prevent unauthorized access
                proxy_ssl_server_name on;
                ${allow-list}
                deny all;

              #   proxy_redirect off;
            		# disable buffering (next 4 lines)
            		# proxy_http_version 1.1;
            		# client_max_body_size 0;
            		# proxy_buffering off;
            		# proxy_request_buffering off;

                # improve download speed from 600 to 1500 MiB/s
                proxy_buffers 32 8k;
                proxy_buffer_size 16k;
                proxy_busy_buffers_size 24k;
                proxy_set_header   Connection        "Keep-Alive";

                # Needed to give the client's real IP to copyparty
                proxy_set_header   Host              $host;
                proxy_set_header   X-Real-IP         $remote_addr;
                proxy_set_header   X-Forwarded-Proto $scheme;
                proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
          '';
        };
      };
    };
  };
  # Copyparty allows us to setup a user password in the module
  # Best not to make it world-readable in the nix-store 
  # We make use of our secrets-flake to decrupt it to the /key
  age.secrets.copyparty_crow_pw = {
    # The secret source file to be decrypted
    file = ./secrets/crow_pw.txt;
    # Folder to decrypt into
    name = "copyparty/crow_pw.txt";

    # Newly created file permissions
    mode = "400";
    owner = "copyparty";
    symlink = true;
  };
}
