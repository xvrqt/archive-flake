{
  services.i2pd = {
    enable = true;
    dataDir = "/zpools/ssd/apps/i2p";
    bandwidth = 512; #KBps
    address = "127.0.0.1";
    proto = {
      http = {
        enable = true;
      };
      socksProxy = {
        enable = true;
      };
      httpProxy = {
        enable = true;
      };
      sam = {
        enable = true;
      };
      i2cp = {
        enable = true; # Torrenting
        port = 7654;
        address = "127.0.0.1";
      };
    };
  };
}

