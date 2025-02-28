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
      dnsTokenFile = config.sops.secrets."cloudflare/CF_DNS_API_TOKEN".path;
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
        graphics = {
          enable = true;
          domain = "graphics.xvrqt.com";
        };
      };
    };

    # Additional Websites that *should* be inside the website flake but are not
    # Likely because they are under active development
    nginx = {
      virtualHosts."archives.irlqt.me" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          root = "/var/www/irlqt";
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
    };
  };
}
