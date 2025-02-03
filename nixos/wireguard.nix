{ machine, ... }:
let
  ip = machine.wireguard.ip;
  port = machine.wireguard.port;
  interface = machine.wireguard.interface;
in
{

  # DNS
  services.blocky = {
    enable = true;
    settings = {
      ports.dns = 53;
      upstreams.groups.default = [
        "https://one.one.one.one/dns-query"
      ];
      customDNS = {
        mapping = {
          "jellyseerr.irlqt.net" = "${ip}";
          "radarr.irlqt.net" = "${ip}";
          "immich.irlqt.net" = "${ip}";
          "sonarr.irlqt.net" = "${ip}";
          "prowlarr.irlqt.net" = "${ip}";
          "nzbget.irlqt.net" = "${ip}";
        };
      };
      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [ "1.1.1.1" "1.0.0.1" ];
      };
      blocking = {
        blackLists = {
          ads = [ "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" ];
        };
        clientGroupsBlock = {
          default = [ "ads" ];
        };
      };
    };
  };

  # enable NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = "enp0s31f6";
  networking.nat.internalInterfaces = [ "${interface}" ];
  networking.firewall = {
    allowedUDPPorts = [ 53 port ];
    allowedTCPPorts = [ 53 ];
  };

  networking.wireguard.interfaces = {
    # "wg0" is the network interface n.net. You can n.net the interface arbitrarily.
    irlqt-secured = {
      ips = [ "${ip}/24" ];
      listenPort = port;
      privateKeyFile = "/home/crow/wg-keys/archive";

      peers = [
        machine.wireguard.peers.spark
        {
          publicKey = "ma+LA7hdq9ayI26Ev0w0MyNFmSUNfBbsDU7+3/85Tis=";
          allowedIPs = [ "2.2.2.3/32" ];
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
