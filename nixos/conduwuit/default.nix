{ pkgs, inputs, ... }: {

  services = {
    conduwuit = {
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
          # Re-enable briefly to add new users. Change the token each time.
          # allow_registration = true;
          # registration_token = "gaygirls";
          app_servicesonfig_files = [
            "/zpools/ssd/apps/conduwuit/matrix-appservice-discord/registration.yaml"
          ];
        };
      };
    };
    # matrix-appservice-discord = {
    #   enable = true;
    #   environmentFile = /etc/keyring/matrix-appservice-discord/tokens.env;
    #   settings = {
    #     bridge = {
    #       domain = "xvrqt.com";
    #       homeServerUrl = "https://matrix.xvrqt.com";
    #     };
    #   };
    # };
  };
}
