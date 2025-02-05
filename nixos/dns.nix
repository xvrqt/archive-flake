let
  ip = "2.2.2.1";
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
          "llm.irlqt.net" = "2.2.2.4";
          "jellyseerr.irlqt.net" = "${ip}";
          "search.irlqt.net" = "${ip}";
          "torrents.irlqt.net" = "${ip}";
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
}
