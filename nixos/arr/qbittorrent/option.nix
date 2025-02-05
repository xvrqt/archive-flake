{ config, lib, pkgs, ... }:
with lib;
let
  UID = 888;
  GID = 888;
  cfg = config.services.qbittorrent;
in
{
  # Create an optin for qbittorrent so it's similar to the rest of the arr stack
  options.services.qbittorrent = {
    enable = mkEnableOption (lib.mdDoc "qBittorrent headless");

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/qbittorrent";
      description = lib.mdDoc ''
        The directory where qBittorrent stores its data files.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = lib.mdDoc ''
        User account under which qBittorrent runs.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = lib.mdDoc ''
        Group under which qBittorrent runs.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      description = lib.mdDoc ''
        qBittorrent web UI port.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Open services.qBittorrent.port to the outside network.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.qbittorrent-nox;
      defaultText = literalExpression "pkgs.qbittorrent-nox";
      description = lib.mdDoc ''
        The qbittorrent package to use.
      '';
    };
  };

  config = mkIf cfg.enable
    {
      # Open the port in the firewall
      networking.firewall = mkIf cfg.openFirewall {
        allowedTCPPorts = [ cfg.port ];
      };

      # Create a systemd service so it runs in the background
      systemd.services.qbittorrent = {
        description = "qBittorrent-nox service";
        documentation = [ "man:qbittorrent-nox(1)" ];
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;

          # Run the pre-start script with full permissions (the "!" prefix) so it
          # can create the data directory if necessary.
          ExecStartPre =
            let
              preStartScript = pkgs.writeScript "qbittorrent-run-prestart" ''
                #!${pkgs.bash}/bin/bash

                # Create data directory if it doesn't exist
                if ! test -d "$QBT_PROFILE"; then
                  echo "Creating initial qBittorrent data directory in: $QBT_PROFILE"
                  install -d -m 0755 -o "${cfg.user}" -g "${cfg.group}" "$QBT_PROFILE"
                fi
              '';
            in
            "!${preStartScript}";

          #ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox";
          ExecStart = "${cfg.package}/bin/qbittorrent-nox";
          # To prevent "Quit & shutdown daemon" from working; we want systemd to
          # manage it!
          #Restart = "on-success";
          #UMask = "0002";
          #LimitNOFILE = cfg.openFilesLimit;
        };

        # Setup ENV vars
        environment = {
          QBT_PROFILE = cfg.dataDir;
          QBT_WEBUI_PORT = toString cfg.port;
        };
      };

      # Create user if doesn't exist
      users.users = mkIf (cfg.user == "qbittorrent") {
        qbittorrent = {
          group = cfg.group;
          uid = UID;
        };
      };

      # Create group if doesn't exist
      users.groups = mkIf (cfg.group == "qbittorrent") {
        qbittorrent = { gid = GID; };
      };
    };
}
