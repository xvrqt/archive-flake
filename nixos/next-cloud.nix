{ pkgs, ... }: {
  environment.etc."nextcloud.pass".text = "GayGirls2025!";
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud30;
    hostName = "cloud.xvrqt.com";
    config = {
      adminuser = "crow";
      adminpassFile = "/etc/nextcloud.pass";
      dbtype = "sqlite";
    };
    settings =
      {
        trusted_domains = [ "localhost" "127.0.0.1" ];
      };
    datadir = "/zpools/hdd/nextcloud";

  };
  services.nginx = {
    # Setup the reverse proxy
    # Plex uses 'xvrqt.com' because it's an external facing service
    virtualHosts."cloud.xvrqt.com" = {
      http2 = true;
      forceSSL = true;
      acmeRoot = null;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:80";
        proxyWebsockets = true;
      };
    };
  };

}
