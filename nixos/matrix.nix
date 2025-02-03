{ pkgs
, config
, ...
}:
let

in

services ={
coturn = {
enable = true;
use-auth-secret = true;
static-auth-secret = "dDIAt0b1zOxQW3bMrhGj9aza3KaoZP9jpmF52kkd8uwQ7UvPFQnfVsn35rtL3ceV";
realm = "turn.xvrqt.com";
no-tcp-relay = true;
no-tls = true;
no-dtls = true;
extraConfig = ''
        user-quota=12
        total-quota=1200
        denied-peer-ip=10.0.0.0-10.255.255.255
        denied-peer-ip=192.168.0.0-192.168.255.255
        denied-peer-ip=172.16.0.0-172.31.255.255

        allowed-peer-ip=192.168.191.127
    '';
};
nginx = {
enable = true;
virtualHosts = {
"matrix.xvrqt.com" = {
forceSSL = true;
enableACME = true;
locations."/" = {
proxyPass = "http://localhost:8448";
};
};
# "riot.xvrqt.com" = {
# 	forceSSL = true;
# 	enableACME = true;
# 	locations."/" = {
# 		root = pkgs.riot-web;	
# 	};
# };
};
};
matrix-synapse = {
enable = true;
# registration_shared_secret = "r5v6TXmxngPT6DJmKb0d9vWYM5Zo07xNMRZpeElg3OtyW0I5zRDWLcbatYl1wUww";
settings = {
server_name = "xvrqt.com";
public_baseurl = "https://matrix.example.com/";
enable_metrics = true;
database_type = "psycopg2";
database_args = {
password = "synapse";
};
# tls_certificate_path = "/var/lib/acme/matrix.example.com/fullchain.pem";
# tls_private_key_path = "/var/lib/acme/matrix.example.com/key.pem";
# database_type = "psycopg2";
# database_args = {
#   database = "matrix-synapse";
# };
turn_uris = [
"turn:turn.dangerousdemos.net:3478?transport=udp"
"turn:turn.dangerousdemos.net:3478?transport=tcp"
];
turn_shared_secret = config.services.coturn.static-auth-secret;
listeners = [
{ # federation
# bind_address = "";
port = 8448;
resources = [
{ compress = true; names = [ "client" "federation" ]; }
];
tls = false;
type = "http";
# x_forwarded = false;
}
#      { # client
# bind_address = "127.0.0.1";
# port = 8008;
# resources = [
#   { compress = true; names = [ "client" "webclient" ]; }
# ];
# tls = false;
# type = "http";
# x_forwarded = true;
#      }
];
};
# extraConfig = ''
#   max_upload_size: "100M"
# '';
};

postgresql = {
enable = true;

## postgresql user and db name remains in the
## service.matrix-synapse.database_args setting which
## by default is matrix-synapse
initialScript = pkgs.writeText "synapse-init.sql" ''
        CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
        CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
            TEMPLATE template0
            LC_COLLATE = "C"
            LC_CTYPE = "C";
        '';
};
# web client proxy and setup certs
# share certs with matrix-synapse and restart on renewal
# security.acme.certs = {
#   "matrix.example.com" = {
#     group = "matrix-synapse";
#     allowKeysForGroup = true;
#     postRun = "systemctl reload nginx.service; systemctl restart matrix-synapse.service";
#   };
# };

};
}
