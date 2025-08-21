{ pkgs, config, ... }:
let
  monero-port = 18080;
  monero-rpc-port = 18081;

  domain = "irlqt.net";
  subDomain = "public.monero.nodes.archive";

in
{

  environment.systemPackages = [
    pkgs.monero-cli
  ];

  networking.firewall = {
    allowedTCPPorts = [ monero-port monero-rpc-port ];
  };


  # You'll need this when you change to exposing the interface directly
  # systemd.services.monero.serviceConfig.ExecStart = lib.mkForce "${lib.getExe' pkgs.monero-cli "monerod"} --config-file=${config.services.monero.dataDir}/monerod.conf --non-interactive --confirm-external-bind";

  services = {
    monero = {
      enable = true;
      # Where to store the block chain
      dataDir = "/zpools/hdd/apps/monero";

      rpc = {
        port = monero-rpc-port;
        address = "127.0.0.1";
        restricted = false;
      };

      limits = {
        threads = 8;
        upload = 1024; # 1 MiB total
      };

      mining = {
        enable = false;
        threads = 1;
        address = "89BkGnoQ1T8KpzuBS2gpkoGcke9r8smfaMZzAexr1QdXT4tSecEJogXDt428qo5msCKPfHdyZASiF3QnoZmvBDXvAJPUq7o";
      };
    };

    # RPC complains if we bind directly to a secure interface and wants us to
    # pass a flag to confirm a direct bind to an interface. We can't easily do
    # that without updating the package, and we want to be public anyways so...
    nginx = {
      virtualHosts."${subDomain}.${domain}" = {
        # Only listen on private interfaces
        listenAddresses = [ "136.27.49.63" "192.168.1.6" "100.64.0.3" "10.128.0.2" ];

        http2 = true;
        forceSSL = true;
        acmeRoot = null;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://${config.services.monero.rpc.address}:${(toString config.services.monero.rpc.port)}";
          # proxyWebsockets = true;
          # recommendedProxySettings = true;
          extraConfig = ''
            proxy_set_header Connection "";
            proxy_http_version 1.1;
            proxy_read_timeout 600s;
            # proxy_ssl_server_name on;
            # proxy_set_header Authorization $http_authorization;
            # proxy_pass_header  Authorization;
            # proxy_pass_request_headers on;
          '';
        };
      };
    };
  };
}
