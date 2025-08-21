{ lib
, pkgs
, inputs
, machine
, ...
}:
let
  # Only secure interfaces can connect to Immich proper
  allow-list = ''
    allow 10.128.0.0/9;
    allow 100.64.0.0/10;
  '';

  # Only listen on secure interfaces
  machines = inputs.networking.config.machines;
  amy-net-interface-ip = machines.${machine}.ip.v4.wg;
  irlqt-net-interface-ip = machines.${machine}.ip.v4.tailnet;
  interfaces = [ amy-net-interface-ip irlqt-net-interface-ip ];

  immich-port = 2283;
  immich-proxy-port = 45541;
in
{

  users.users.immich = {
    home = "/var/lib/immich";
    createHome = true;
  };


  environment.systemPackages = [
    # Easier administration from the CLI for some tasks
    pkgs.immich-go
    pkgs.immich-cli

    # Tools for enabling hardware acceleration in Immich
    pkgs.nvidia-docker
    pkgs.nvidia-vaapi-driver

    # Tools for converting images, making them smaller, and organizing them
    # outside of Immich
    pkgs.oxipng # PNG Crusher
    pkgs.exiftool # EXIF Data Reading/Writing
    pkgs.imagemagick # Image Manipulation Program
  ];

  users.users.immich = {
    # Not a real user
    isSystemUser = true;
    # Ostensibly enables video rendering
    extraGroups = [ "video" "render" ];
  };

  systemd.services = {
    immich-server.serviceConfig.PrivateDevices = lib.mkForce false;
    immich-machine-learning.serviceConfig = {
      PrivateDevices = lib.mkForce false;
    };
  };

  services = {
    # Allow people to share outside the irlqt-net
    immich-public-proxy = {
      enable = true;

      port = immich-proxy-port;
      immichUrl = "http://127.0.0.1:${toString immich-port}";
      openFirewall = true;
    };

    immich = {
      enable = true;

      user = "immich";
      group = "media-players";

      port = immich-port;
      host = "127.0.0.1";
      openFirewall = true;

      mediaLocation = "/zpools/hdd/media/images/immich";

      database.createDB = true;
      # accelerationDevices = [ "/dev/nvidia0" "/dev/nvidiactl" "/dev/nvidia-uvm" ];
      machine-learning.enable = true;
    };

    nginx = {
      virtualHosts."immich.irlqt.net" = {
        # Only listen on private interfaces
        # listenAddresses = interfaces ++ [ "127.0.0.1" ];
        listenAddresses = interfaces;

        forceSSL = true;
        enableACME = true;
        acmeRoot = null;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString immich-port}";
          proxyWebsockets = true;
          recommendedProxySettings = true;

          # Only allow people connected via secure interfaces connect
          extraConfig = ''
            proxy_ssl_server_name on;
            client_max_body_size 5000M;

            proxy_read_timeout 600s;
            proxy_send_timeout 600s;
            send_timeout 600s;

            ${allow-list}
            deny all;
          '';
        };
      };

      # For the share proxy
      virtualHosts."immich.public.irlqt.net" = {
        # Listen on all interfaces
        listenAddresses = interfaces ++ [ "192.168.1.6" "136.27.49.63" "127.0.0.1" ];

        forceSSL = true;
        enableACME = true;
        acmeRoot = null;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString immich-proxy-port}";
          proxyWebsockets = true;
          recommendedProxySettings = true;

          extraConfig = ''
            proxy_ssl_server_name on;
            client_max_body_size 5000M;

            proxy_read_timeout 600s;
            proxy_send_timeout 600s;
            send_timeout 600s;
          '';
        };
      };
    };
  };

  # Possibly necessary during a recovery scenario to prevent the service from
  # setting up a database which has been cleared in preparation for a restore
  # environment.sessionVariables = {
  #   "DB_SKIP_MIGRATIONS" = "true";
  # };
  # postgresql = {
  #   ensureDatabases = [ "immich" ];
  # };
}
