# Websites Hosted by NGINX
{ pkgs
, config
, inputs
, ...
}:
let
in {
  services = {
    # Rely on the xvrqt/websites-flake
    # Hosted in the Nix-Store 
    websites = {
      enable = true;
      dnsProvider = "cloudflare";
      # dnsTokenFile = config.sops.secrets."cloudflare/CF_DNS_API_TOKEN".path;
      sites = {
        http-status-codes = {
          enable = true;
          domain = "http.xvrqt.com";
        };
        homepage = {
          enable = true;
          domain = "xvrqt.com";
        };
        dino-game = {
          enable = true;
          domain = "dino.xvrqt.com";
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
        # Run on the lighthouse (since it's the homepage for that machine)
        irlqt-net = {
          enable = false;
          domain = "irlqt.net";
        };
      };
    };

    # Additional Websites that *should* be inside the website flake but are not
    # Likely because they are under active development
    nginx = {
      # appendHttpConfig = ''
      #   map $server_addr $root {
      #     10.128.0.1 "/var/www/dorkweb";
      #     default "/var/www/dorktest";
      #   }
      # '';
      virtualHosts."archives.irlqt.me" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          root = "/var/www/irlqt";
        };
      };

      virtualHosts."girls.irlqt.me" = {
        listenAddresses = [ "10.128.0.1" "192.168.1.6" ];
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;

        extraConfig = ''
          root $root;
          set $root /var/www/dorktest;
          if ($server_addr = "10.128.0.1") {
            set $root /var/www/dorkweb;
          }
        '';
        # locations."/" = {
        #   root = "$root";
        # };
      };

      virtualHosts."webgl.irlqt.me" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          root = "/var/www/webgl";
        };
      };
    };
  };
}
