# NGINX Reverse Proxies for Services
# TODO: Move these to where they live
let
  serverName = "xvrqt.com";
  matrixDomain = "matrix.xvrqt.com";

  clientConfig."m.homeserver".base_url = "https://${matrixDomain}";
  clientConfig."m.homeserver".server_name = "xvrqt.com";
  # clientConfig."m.identity_server".base_url = "https://vector.im";
  clientConfig."org.matrix.msc3575.proxy".url = "https://${matrixDomain}";

  serverConfig."m.server" = "${matrixDomain}:443";
  mkWellKnown = data: ''
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
in
{
  services = {
    nginx = {
      virtualHosts."ollama.irlqt.net" = {
        locations."/" = {
          proxyPass = "http://10.128.0.4:6547";
          proxyWebsockets = true;
        };
      };
      virtualHosts."xvrqt.com" = {
        locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
        locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
        locations."/_matrix" = {
          proxyPass = "http://127.0.0.1:6167";
          proxyWebsockets = true;
        };
      };
      virtualHosts."kofi.xvrqt.com" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        globalRedirect = "ko-fi.com/xvrqt";
      };
      virtualHosts."matrix.xvrqt.com" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        # locations."~ ^(/_matrix|/_synapse/client)" = {
        #   proxyPass = "http://127.0.0.7:6167";
        #   extraConfig = ''
        #     client_max_body_size 50M;
        #     proxy_http_version 1.1;

        #     proxy_set_header X-Forwarded-For $remote_addr;
        #     proxy_set_header X-Forwarded-Proto $scheme;
        #     proxy_set_header Host $host;
        #   '';
        # };
        # locations."~ ^/(client/|_matrix/client/unstable/org.matrix.msc3575/sync)" = {
        #   proxyPass = "http://localhost:6168";
        #   extraConfig = ''
        #     proxy_set_header X-Forwarded-For $remote_addr;
        #     proxy_set_header X-Forwarded-Proto $scheme;
        #     proxy_set_header Host $host;
        #   '';
        # };
        locations."/" = {
          proxyPass = "http://127.0.0.1:6167";
          proxyWebsockets = true;
          # extraConfig = ''
          #   allow 2.2.2.0/24;
          #   deny all;
          # '';
        };
      };
      # virtualHosts."immich.xvrqt.com" = {
      virtualHosts."immich.irlqt.net" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:2283";
          proxyWebsockets = true;
          recommendedProxySettings = true;
          # proxy_http_version 1.1;
          extraConfig = ''
            	    client_max_body_size 5000M;


            allow 10.128.0.0/9;
                  deny all;
            	    proxy_read_timeout 600s;
            	    proxy_send_timeout 600s;
            	    send_timeout 600s;
          '';
        };
      };
      # virtualHosts."jellyfin.irlqt.me" = {
      #   forceSSL = true;
      #   http2 = true;
      #   enableACME = true;
      #   acmeRoot = null;
      #   locations."/" = {
      #     proxyPass = "http://127.0.0.1:8096";
      #     proxyWebsockets = true;
      #   };
      # };
    };
  };
}
