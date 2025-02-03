{ pkgs, inputs, ... }: {

  services.conduwuit = {
    enable = true;
    package = inputs.conduwuit.packages.${pkgs.system}.default;
    settings = {
      global = {
        port = [ 6167 ];
        address = [ "127.0.0.1" ];
        server_name = "xvrqt.com";
        database_backend = "rocksdb";
        allow_registration = false;
        allow_federation = true;
        # allow_encryption = true;
        trusted_servers = [ "matrix.org" "mozilla.org" ];
        # allow_registration = true;
        # registration_token = "gaygirls";
        # database_path = "/zpools/ssd/apps/conduwuit";
        # 
      };
    };
  };
}
