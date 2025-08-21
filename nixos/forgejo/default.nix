{ lib
, config
, inputs
, machine
, ...
}:
let
  name = "forgejo";
  cfg = config.services."${name}";

  userInfo = inputs.identities.userInfo;
  allPublicKeys = lib.attrsets.mapAttrsToList (_: value: value.ssh.publicKey) userInfo;

  addresses = inputs.networking.config.machines.${machine}.ip.v4;
  amy-net-interface = addresses.wg;
  irlqt-net-interface = addresses.tailnet;

  port = 3232;
  address = "127.0.0.1";
  domain = "irlqt.net";
  subDomain = "git";
in
{
  # Add my users to the git group, add their keys as authorized so they can all push 
  users.groups.git.members = [ "crow" ];
  users.users.forgejo.openssh.authorizedKeys.keys = allPublicKeys;

  services = {
    forgejo = {
      enable = true;

      user = "forgejo";
      group = "git";

      # Store on the HDD for extra data integrity
      stateDir = "/zpools/hdd/git/forgejo";

      settings = {
        server = {
          DOMAIN = "${subDomain}.${domain}";
          ROOT_URL = "https://${subDomain}.${domain}/";
          HTTP_PORT = port;
          HTTP_ADDR = "127.0.0.1";
        };

        # Manual user creation only
        # Maybe this can be changed now that it's only accessible on the
        # irlqt-net
        service = {
          DISABLE_REGISTRATION = true;
        };
      };

      database = {
        type = "postgres";
      };
      # Git Large File Storage
      lfs.enable = true;
    };

    # Add git to the users allowed to use sshd
    openssh.settings.AllowUsers = [ "forgejo" ];

    nginx = {
      # Setup the reverse proxy
      virtualHosts."${subDomain}.${domain}" = {
        # Only listen on secured interfaces
        listenAddresses = [ amy-net-interface irlqt-net-interface ];

        http2 = true;
        forceSSL = true;
        acmeRoot = null;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://${address}:${(builtins.toString port)}";
          proxyWebsockets = true;
          recommendedProxySettings = true;

          extraConfig = ''
            client_max_body_size 512M;
          '';
        };
      };
    };
  };

  # Setup the admin account with the secret password
  systemd.services.forgejo-admin-password =
    let
      cmd = "${cfg.package}/bin/gitea admin user";
      pwd = config.age.secrets.forgejo_admin_password.path;
      cfgPath = "/zpools/hdd/git/forgejo/custom/conf/app.ini";
      # Admin user name
      user = "crow";
      admin_email = "git@xvrqt.com";
    in
    {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "forgejo";
        Group = "git";
      };
      script = "${cmd} create --admin --email ${admin_email} --username ${user} --password \"$(tr - d '/n' < ${pwd})\" --config ${cfgPath} || true";
    };

  # Setup the admin password using a secret
  # Relies on the secrets-flake, stored on the /key
  age.secrets.forgejo_admin_password = {
    # The secret source file to be decrypted
    file = ./secrets/forgejo_admin_password.txt;
    # Folder to decrypt into
    name = "git/forgejo/admin_password.txt";

    # Newly created file permissions
    mode = "400";
    owner = "forgejo";
    symlink = true;
  };
}
