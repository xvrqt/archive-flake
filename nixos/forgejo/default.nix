{ lib
, config
, ...
}:
let
  userInfo = (builtins.getFlake "github:xvrqt/identities-flake").userInfo;
  allPublicKeys = lib.attrsets.mapAttrsToList (_: value: value.ssh.publicKey) userInfo;
  cfg = config.services.forgejo;

  name = "forgejo";
  port = 3232;
  address = "127.0.0.1";
  domain = "irlqt.net";
  subDomain = "git";

in

{
  users.groups.git.members = [ "crow" ];
  users.users.forgejo.openssh.authorizedKeys.keys = allPublicKeys;
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
  services = {
    openssh.settings.AllowUsers = [ "forgejo" ];
    nginx = {
      # Setup the reverse proxy
      virtualHosts."${subDomain}.${domain}" = {
        http2 = true;
        forceSSL = true;
        acmeRoot = null;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://${address}:${(builtins.toString port)}";
          proxyWebsockets = true;
          # Only allow people connected via Wireguard to connect
          extraConfig = ''
            client_max_body_size 512M;
          '';
        };
      };
    };
    # allow 2.2.2.0/24;
    # deny all;
    forgejo = {
      enable = true;

      user = "forgejo";
      group = "git";

      stateDir = "/zpools/hdd/git/forgejo";

      settings = {
        server = {
          DOMAIN = "git.irlqt.net";
          ROOT_URL = "https://git.irlqt.net/";
          HTTP_PORT = port;
          HTTP_ADDR = "127.0.0.1";
        };

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
  };
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
}
