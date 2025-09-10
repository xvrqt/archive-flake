# Websites Hosted by NGINX
{ pkgs
, config
, inputs
, ...
}:
let
in {
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services = {
    # Rely on the xvrqt/websites-flake
    # Hosted in the Nix-Store 
    websites = {
      enable = true;
      dnsProvider = "cloudflare";

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
        moomin-orb = {
          enable = true;
          domain = "orb.xvrqt.com";
        };
        game-of-life = {
          enable = true;
          domain = "gol.xvrqt.com";
        };
      };
    };


    # Additional Websites that *should* be inside the website flake but are not
    # Likely because they are under active development
    nginx = {
      # Little fun website
      # TODO move to it's own website flake
      virtualHosts."archives.irlqt.me" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          root = "/var/www/irlqt";
        };
      };
    };
  };
}
