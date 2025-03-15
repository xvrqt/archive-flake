{
  services = {
    # So I can view the status remotely
    nginx = {
      virtualHosts."i2p.irlqt.net" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:7070";
          proxyWebsockets = true;
        };
      };
    };

    i2pd = {
      enable = true;

      port = 8383;

      bandwidth = 2048; #KBps

      enableIPv4 = true;
      enableIPv6 = true;

      dataDir = "/zpools/ssd/apps/i2p";

      # Better resistance to automated identification and attacks
      ntcp2 = {
        enable = true;
        port = 8484;
      };

      proto = {
        http = {
          enable = true;
          # So the above proxy works
          strictHeaders = false;
          port = 7070;
        };
        socksProxy = {
          enable = true;
          address = "2.2.2.1";
          port = 4447;
        };
        httpProxy = {
          enable = true;
          address = "2.2.2.1";
          port = 4444;
        };
        # Used for torrenting 
        sam = {
          enable = true;
          port = 7656;
        };
        i2cp = {
          enable = true; # Torrenting
          port = 7654;
          address = "127.0.0.1";
        };
      };
    };
  };
}

