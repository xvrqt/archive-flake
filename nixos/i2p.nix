{
  services.i2pd = {
    enable = true;
    dataDir = "/zpools/ssd/apps/i2p";
    bandwidth = 512; #KBps
    address = "127.0.0.1";
    proto = {
      sam = {
        enable = true;
      };
    };
    # i2cp = {
    #   enable = true; # Torrenting
    #   address = "127.0.0.1";
    #   port = 7654;
    # };
  };
}

